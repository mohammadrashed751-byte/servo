import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/api_client.dart';
import 'package:servo/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:servo/feature/auth/data/repositories/auth_repository_imp.dart';
import 'package:servo/feature/auth/prsentation/cubit/reset_password_cubit.dart';
import 'package:servo/feature/auth/prsentation/state/reset_password_state.dart';
import 'package:servo/feature/auth/prsentation/screen/forgot_password_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/reset_email_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/new_password_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/login_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/register_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/screen_one.dart';
import 'package:servo/main.dart';

// Test-only responses; production always uses the existing Dio API client.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  final started = Completer<void>();
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (!started.isCompleted) started.complete();
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _response(Object body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
ResponseBody _ok() => _response({'success': true});
_Adapter _install(FutureOr<ResponseBody> Function(RequestOptions) respond) {
  final previous = ApiClient.dio.httpClientAdapter;
  final adapter = _Adapter(respond);
  ApiClient.dio.httpClientAdapter = adapter;
  addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
  return adapter;
}

AuthRepositoryImpl _repository() => AuthRepositoryImpl(AuthRemoteDataSource());
Future<void> _reset(AuthRepositoryImpl repository) => repository.resetPassword(
  token: 'test-token',
  email: 'reader@example.invalid',
  password: 'ExampleOnly123!',
  passwordConfirmation: 'ExampleOnly123!',
);
Future<void> _mount(
  WidgetTester tester,
  Widget child, {
  bool app = false,
}) async {
  tester.view.physicalSize = const Size(500, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app ? child : MaterialApp(home: child));
  await tester.pumpAndSettle();
}

Future<void> _fillPassword(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'ExampleOnly123!');
  await tester.enterText(find.byType(TextFormField).at(1), 'ExampleOnly123!');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Save Password'));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'recovery request contracts exclude stored authentication and persist no secrets',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'existing-login',
        'setting': true,
      });
      final adapter = _install((_) => _ok());
      final repository = _repository();
      await repository.forgotPassword(' reader@example.invalid ');
      await _reset(repository);
      expect(adapter.requests[0].uri.path, '/api/v1/auth/password/forgot');
      expect(adapter.requests[0].data, {'email': 'reader@example.invalid'});
      expect(adapter.requests[1].uri.path, '/api/v1/auth/password/reset');
      expect(adapter.requests[1].data, {
        'email': 'reader@example.invalid',
        'token': 'test-token',
        'password': 'ExampleOnly123!',
        'password_confirmation': 'ExampleOnly123!',
      });
      expect(
        adapter.requests.every((r) => !r.headers.containsKey('Authorization')),
        isTrue,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'auth_token', 'setting'});
      expect(prefs.getString('auth_token'), 'existing-login');
    },
  );

  for (final status in [400, 401, 403, 410, 422, 429, 500]) {
    test('HTTP $status fails safely and never leaks server payloads', () async {
      _install(
        (_) => _response({
          'message': 'PRIVATE_TOKEN_STACK_TRACE',
          'errors': {
            'token': ['PRIVATE_TOKEN_STACK_TRACE'],
          },
        }, status),
      );
      await expectLater(
        _reset(_repository()),
        throwsA(
          isA<PasswordRecoveryException>().having(
            (e) => e.message,
            'safe message',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
    });
  }
  test('password validation gives a useful safe message', () async {
    _install(
      (_) => _response({
        'errors': {
          'password': ['PRIVATE_PASSWORD'],
        },
      }, 422),
    );
    await expectLater(
      _reset(_repository()),
      throwsA(
        isA<PasswordRecoveryException>().having(
          (e) => e.message,
          'message',
          contains('stronger'),
        ),
      ),
    );
  });
  test(
    'HTML response and false success never report a password change',
    () async {
      var html = true;
      _install(
        (_) => html
            ? ResponseBody.fromString(
                '<html>PRIVATE</html>',
                200,
                headers: {
                  Headers.contentTypeHeader: ['text/html'],
                },
              )
            : _response({'success': false, 'message': 'PRIVATE'}),
      );
      await expectLater(
        _reset(_repository()),
        throwsA(isA<PasswordRecoveryException>()),
      );
      html = false;
      await expectLater(
        _reset(_repository()),
        throwsA(isA<PasswordRecoveryException>()),
      );
    },
  );
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
  ]) {
    test('$type returns a safe retryable error', () async {
      _install((r) => throw DioException(requestOptions: r, type: type));
      await expectLater(
        _repository().forgotPassword('reader@example.invalid'),
        throwsA(isA<PasswordRecoveryException>()),
      );
    });
  }
  test(
    'reset Cubit guards validation, duplicates, and disposal during a request',
    () async {
      final pending = Completer<ResponseBody>();
      final adapter = _install((_) => pending.future);
      final cubit = ResetPasswordCubit(_repository());
      Future<void> submit({
        String token = 'test-token',
        String password = 'ExampleOnly123!',
        String confirmation = 'ExampleOnly123!',
      }) => cubit.resetPassword(
        token: token,
        email: 'reader@example.invalid',
        password: password,
        passwordConfirmation: confirmation,
      );
      await submit(token: '');
      expect(cubit.state, isA<ResetPasswordFailure>());
      await submit(password: 'short');
      await submit(confirmation: 'different');
      expect(adapter.requests, isEmpty);
      final first = submit();
      await submit();
      await adapter.started.future;
      expect(adapter.requests, hasLength(1));
      await cubit.close();
      pending.complete(_ok());
      await first;
    },
  );
  test('existing login and signup keep their contracts', () async {
    final adapter = _install(
      (r) => r.path == 'auth/login'
          ? _response({
              'success': true,
              'data': {
                'token': 'login-token',
                'user': {
                  'id': 1,
                  'name': 'Reader',
                  'email': 'reader@example.invalid',
                  'role': 'customer',
                },
              },
            })
          : _ok(),
    );
    final repository = _repository();
    final user = await repository.login(
      'reader@example.invalid',
      'ExampleOnly123!',
    );
    expect(user.token, 'login-token');
    await repository.register(
      name: 'Reader',
      email: 'reader@example.invalid',
      password: 'ExampleOnly123!',
      passwordConfirmation: 'ExampleOnly123!',
      phone: '0791234567',
      role: 'customer',
    );
    expect(adapter.requests.map((r) => r.path), [
      'auth/login',
      'auth/register',
    ]);
  });

  testWidgets(
    'forgot validates, prevents duplicates, and confirms only after API success',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final adapter = _install((_) => pending.future);
      await _mount(tester, const ForgotPasswordScreen());
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(adapter.requests, isEmpty);
      await tester.enterText(
        find.byType(TextFormField),
        'reader@example.invalid',
      );
      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      for (var i = 0; i < 20 && adapter.requests.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.byType(ResetEmailScreen), findsNothing);
      expect(adapter.requests, hasLength(1));
      pending.complete(_ok());
      await tester.pumpAndSettle();
      expect(find.byType(ResetEmailScreen), findsOneWidget);
      await tester.tap(find.text('Go to Login page'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
        isFalse,
      );
    },
  );
  testWidgets('forgot failure stays on the form and permits retry', (
    tester,
  ) async {
    var failure = true;
    _install((_) => failure ? _response({'message': 'PRIVATE'}, 500) : _ok());
    await _mount(tester, const ForgotPasswordScreen());
    await tester.enterText(
      find.byType(TextFormField),
      'reader@example.invalid',
    );
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetEmailScreen), findsNothing);
    expect(find.textContaining('Please try again later'), findsOneWidget);
    expect(find.textContaining('PRIVATE'), findsNothing);
    failure = false;
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetEmailScreen), findsOneWidget);
  });
  testWidgets('missing link offers recovery without submitting a reset', (
    tester,
  ) async {
    final adapter = _install((_) => _ok());
    await _mount(tester, const NewPasswordScreen());
    expect(find.byType(TextFormField), findsNothing);
    await tester.tap(find.text('Request a new reset link'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });
  testWidgets(
    'reset validates mismatch then waits for success and clears the form',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final adapter = _install((_) => pending.future);
      await _mount(
        tester,
        const NewPasswordScreen(
          email: 'reader@example.invalid',
          token: 'test-token',
        ),
      );
      await _fillPassword(tester);
      await tester.enterText(find.byType(TextFormField).at(1), 'different');
      await tester.tap(find.text('Save Password'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(adapter.requests, isEmpty);
      await _fillPassword(tester);
      await tester.tap(find.text('Save Password'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.text('Password updated successfully'), findsNothing);
      pending.complete(_ok());
      await tester.pumpAndSettle();
      expect(find.text('Password updated successfully'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await tester.tap(find.text('Go to Login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
        isFalse,
      );
      expect(adapter.requests, hasLength(1));
    },
  );
  testWidgets('expired or used link stays on reset and offers a new link', (
    tester,
  ) async {
    _install(
      (_) => _response({
        'errors': {
          'token': ['PRIVATE'],
        },
      }, 422),
    );
    await _mount(
      tester,
      const NewPasswordScreen(
        email: 'reader@example.invalid',
        token: 'test-token',
      ),
    );
    await _fillPassword(tester);
    await tester.tap(find.text('Save Password'));
    await tester.pumpAndSettle();
    expect(find.textContaining('invalid or expired'), findsOneWidget);
    expect(find.text('Password updated successfully'), findsNothing);
    expect(find.textContaining('PRIVATE'), findsNothing);
  });
  testWidgets('forgot completion after leaving the screen does not navigate', (
    tester,
  ) async {
    final pending = Completer<ResponseBody>();
    _install((_) => pending.future);
    await _mount(tester, const ForgotPasswordScreen());
    await tester.enterText(
      find.byType(TextFormField),
      'reader@example.invalid',
    );
    await tester.tap(find.text('Reset Password'));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: Text('Other page')));
    pending.complete(_ok());
    await tester.pumpAndSettle();
    expect(find.text('Other page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('normal app startup stays on ScreenOne', (tester) async {
    final adapter = _install((_) => _ok());
    await _mount(tester, const MyApp(), app: true);
    expect(find.byType(ScreenOne), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });
  testWidgets(
    'cold reset route decodes credentials without putting them in route settings',
    (tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          '/reset-password?email=reader%2Btest%40example.invalid&token=test%2Btoken';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await _mount(tester, const MyApp(), app: true);
      final screen = tester.widget<NewPasswordScreen>(
        find.byType(NewPasswordScreen),
      );
      expect(screen.email, 'reader+test@example.invalid');
      expect(screen.token, 'test+token');
      expect(
        ModalRoute.of(
          tester.element(find.byType(NewPasswordScreen)),
        )!.settings.name,
        isNull,
      );
    },
  );
  testWidgets('warm route and duplicate token rejection', (tester) async {
    await _mount(tester, const MyApp(), app: true);
    await tester.binding.handlePushRoute(
      '/reset-password?email=reader%40example.invalid&token=one&token=two',
    );
    await tester.pumpAndSettle();
    expect(find.byType(NewPasswordScreen), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });
  testWidgets('login still opens forgot and signup screens', (tester) async {
    await _mount(tester, const LoginScreen());
    final forgot = find.textContaining('Forgot');
    await tester.ensureVisible(forgot);
    await tester.tap(forgot);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ForgotPasswordScreen))).pop();
    await tester.pumpAndSettle();
    final signup = find.text('Sign Up');
    await tester.ensureVisible(signup);
    await tester.tap(signup);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
