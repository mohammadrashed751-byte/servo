import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/local_storage.dart';
import 'package:servo/core/network/api_client.dart';
import 'package:servo/feature/user_account/account/data/datasources/profile_local_store.dart';
import 'package:servo/feature/user_account/account/presentation/screen/change_password_screen.dart';
import 'package:servo/feature/user_account/account/presentation/screen/profile_screen.dart';
import 'package:servo/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:servo/feature/auth/data/repositories/auth_repository_imp.dart';
import 'package:servo/feature/auth/prsentation/screen/login_screen.dart';
import '../support/profile_test_store.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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
_Adapter _install(FutureOr<ResponseBody> Function(RequestOptions) respond) {
  final previous = ApiClient.dio.httpClientAdapter;
  final adapter = _Adapter(respond);
  ApiClient.dio.httpClientAdapter = adapter;
  addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
  return adapter;
}

Future<void> _mount(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String confirmation) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'OldPassword123');
  await tester.enterText(find.byType(TextFormField).at(1), 'NewPassword123');
  await tester.enterText(find.byType(TextFormField).at(2), confirmation);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.ensureVisible(find.text('Save Password'));
  await tester.tap(find.text('Save Password'));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'session',
      'user_role': 'client',
      'unrelated': true,
    });
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  test(
    'change uses authenticated PUT; subsequent login sends the new password',
    () async {
      var serverPassword = 'OldPassword123';
      final adapter = _install((request) {
        final data = request.data as Map;
        if (request.path == 'me/password') {
          expect(request.method, 'PUT');
          expect(request.headers['Authorization'], 'Bearer session');
          expect(data['current_password'], serverPassword);
          expect(data['password_confirmation'], data['password']);
          serverPassword = data['password'] as String;
          return _response({'success': true});
        }
        if (data['password'] != serverPassword) {
          return _response({
            'success': false,
            'message': 'Invalid credentials',
          }, 401);
        }
        return _response({
          'success': true,
          'data': {
            'user': {
              'id': 1,
              'name': 'Test',
              'email': 'test@example.invalid',
              'role': 'client',
            },
            'token': 'new-session',
          },
        });
      });
      final repository = AuthRepositoryImpl(AuthRemoteDataSource());
      await repository.changePassword(
        currentPassword: 'OldPassword123',
        password: 'NewPassword123',
        passwordConfirmation: 'NewPassword123',
      );
      expect(
        (await repository.login(
          'test@example.invalid',
          'NewPassword123',
        )).token,
        'new-session',
      );
      await expectLater(
        repository.login('test@example.invalid', 'OldPassword123'),
        throwsException,
      );
      expect(adapter.requests.length, 3);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'auth_token', 'user_role', 'unrelated'});
      expect(prefs.getString('auth_token'), 'session');
    },
  );
  test('incorrect current password and false success are errors', () async {
    var invalidPassword = true;
    _install(
      (_) => invalidPassword
          ? _response({
              'errors': {
                'current_password': ['invalid'],
              },
            }, 422)
          : _response({'success': false}),
    );
    final source = AuthRemoteDataSource();
    Future<void> change() => source.changePassword(
      currentPassword: 'wrong',
      password: 'NewPassword123',
      passwordConfirmation: 'NewPassword123',
    );
    await expectLater(
      change(),
      throwsA(
        isA<AccountAuthException>().having(
          (e) => e.message,
          'message',
          contains('current password'),
        ),
      ),
    );
    invalidPassword = false;
    await expectLater(change(), throwsA(isA<AccountAuthException>()));
  });
  test('logout revokes server session and clears only user data', () async {
    final preferences = TestProfilePreferences()
      ..values['servo.profile.v1'] = '{}';
    final adapter = _install((r) {
      expect(r.path, 'auth/logout');
      expect(r.method, 'POST');
      expect(r.headers['Authorization'], 'Bearer session');
      return _response({'success': true});
    });
    await AuthRepositoryImpl(
      AuthRemoteDataSource(),
      profileStore: ProfileLocalStore(preferences: preferences),
    ).logout();
    expect(adapter.requests.length, 1);
    expect(await LocalStorage.getToken(), isNull);
    expect(await LocalStorage.getRole(), isNull);
    expect(preferences.values, isEmpty);
    expect((await SharedPreferences.getInstance()).getBool('unrelated'), true);
  });
  test(
    'failed logout retains session for retry; 401 clears expired session',
    () async {
      var expired = false;
      _install((_) => _response({'success': false}, expired ? 401 : 500));
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSource(),
        profileStore: ProfileLocalStore(preferences: TestProfilePreferences()),
      );
      await expectLater(
        repository.logout(),
        throwsA(isA<AccountAuthException>()),
      );
      expect(await LocalStorage.getToken(), 'session');
      expired = true;
      await repository.logout();
      expect(await LocalStorage.getToken(), isNull);
    },
  );
  testWidgets(
    'password success follows confirmed server update and clears fields',
    (tester) async {
      final pending = Completer<ResponseBody>();
      _install((_) => pending.future);
      var completed = false;
      await _mount(
        tester,
        ChangePasswordScreen(onHomePage: () => completed = true),
      );
      await _fill(tester, 'NewPassword123');
      await tester.pump(const Duration(milliseconds: 100));
      expect(completed, false);
      pending.complete(_response({'success': true}));
      await tester.pumpAndSettle();
      expect(completed, true);
      expect(
        find.textContaining('Password changed successfully.'),
        findsOneWidget,
      );
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(field.controller!.text, isEmpty);
      }
    },
  );

  testWidgets('mismatched confirmation never reaches the backend', (
    tester,
  ) async {
    final adapter = _install((_) => _response({'success': true}));
    await _mount(tester, const ChangePasswordScreen());
    await _fill(tester, 'different');
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });
  testWidgets('password request loads once and displays backend failure', (
    tester,
  ) async {
    final pending = Completer<ResponseBody>();
    final adapter = _install((_) => pending.future);
    await _mount(tester, const ChangePasswordScreen());
    await _fill(tester, 'NewPassword123');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(adapter.requests.length, 1);
    pending.complete(
      _response({
        'errors': {
          'current_password': ['invalid'],
        },
      }, 422),
    );
    await tester.pumpAndSettle();
    expect(find.text('The current password is incorrect.'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });
  testWidgets('logout replaces all protected navigation with Login', (
    tester,
  ) async {
    _install((_) => _response({'success': true}));
    final store = ProfileLocalStore(preferences: TestProfilePreferences());
    await _mount(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProfileScreen(profileStore: store),
              ),
            ),
            child: const Text('Protected Home'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Protected Home'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(await LocalStorage.getToken(), isNull);
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(navigator.canPop(), false);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.text('Protected Home'), findsNothing);
  });
}
