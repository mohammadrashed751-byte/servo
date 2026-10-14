import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/api_client.dart';
import 'package:servo/feature/company_account/account/data/datasources/company_profile_store.dart';
import 'package:servo/feature/company_account/account/data/models/company_profile.dart';
import 'package:servo/feature/company_account/account/presentation/screen/company_profile_screen.dart';
import 'package:servo/feature/company_account/account/presentation/screen/company_change_password_screen.dart';
import 'package:servo/feature/company_account/account/presentation/screen/company_faq_screen.dart';
import 'package:servo/feature/auth/prsentation/screen/login_screen.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody response(Object body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
const profile = CompanyProfile(
  id: 41,
  name: 'Company Test',
  email: 'company@example.invalid',
  phone: '0791234567',
  specialization: 'IT',
  pushEnabled: true,
);

class FakeStore extends CompanyProfileStore {
  CompanyProfile current = profile;
  bool failSave = false;
  bool failNotifications = false;
  @override
  Future<CompanyProfile> load() async => current;
  @override
  Future<void> save(CompanyProfile value) async {
    if (failSave) throw StateError('test failure');
    current = value;
  }

  @override
  Future<void> setPushNotifications(bool enabled) async {
    if (failNotifications) throw StateError('test failure');
  }
}

final previewKey = GlobalKey();
Future<void> preview(WidgetTester tester, String name) async {
  final output = Platform.environment['COMPANY_ACCOUNT_PREVIEW_DIR'];
  if (output == null) return;
  await tester.pumpAndSettle();
  final boundary =
      previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(output).create(recursive: true);
    await File('$output/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> mount(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: previewKey,
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-session',
      'user_role': 'provider',
    });
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test(
    'profile requests persist supported fields and isolate specialization by ID',
    () async {
      var id = 41;
      var saves = 0;
      var shouldFail = false;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/'));
      dio.httpClientAdapter = Adapter((request) {
        if (request.method == 'GET') {
          return response({
            'success': true,
            'data': {
              'id': id,
              'name': 'Company Test',
              'email': 'company@example.invalid',
              'phone': '0791234567',
              'role': 'provider',
              'push_enabled': true,
            },
          });
        }
        expect(request.method, 'PUT');
        if (request.path == 'me/preferences') {
          expect(request.data, {'push_enabled': false});
        } else {
          expect(request.path, 'me');
          expect(request.data, {
            'name': profile.name,
            'email': profile.email,
            'phone': profile.phone,
          });
          saves++;
        }
        return response({'success': !shouldFail});
      });
      final store = CompanyProfileStore(client: dio);
      expect((await store.load()).name, 'Company Test');
      await store.save(profile);
      expect((await store.load()).specialization, 'IT');
      id = 42;
      expect((await store.load()).specialization, isEmpty);
      await store.setPushNotifications(false);
      shouldFail = true;
      await expectLater(store.save(profile), throwsFormatException);
      expect(saves, 2);
    },
  );

  testWidgets(
    'profile edits update visible company; failed notification update keeps switch',
    (tester) async {
      final store = FakeStore()..failNotifications = true;
      await mount(
        tester,
        CompanyProfileScreen(onGoHomepage: () {}, profileStore: store),
      );
      expect(find.text('Company Test'), findsOneWidget);
      await preview(tester, 'profile');
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Company Name'), findsOneWidget);
      expect(find.text('Company Email'), findsOneWidget);
      await preview(tester, 'edit-profile');
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Updated Company',
      );
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.text('Updated Company'), findsOneWidget);
      expect(store.current.id, 41);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('contact FAQ routes back to company homepage callback', (
    tester,
  ) async {
    final previous = ApiClient.dio.httpClientAdapter;
    ApiClient.dio.httpClientAdapter = Adapter((request) {
      if (request.path == 'settings') {
        return response({
          'success': true,
          'data': {
            'support': {
              'email': 'support@example.invalid',
              'phone': '0791234567',
            },
          },
        });
      }
      expect(request.path, 'faqs');
      return response({'success': true, 'data': []});
    });
    addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
    var homeCalls = 0;
    await mount(
      tester,
      CompanyProfileScreen(
        onGoHomepage: () => homeCalls++,
        profileStore: FakeStore(),
      ),
    );
    await tester.ensureVisible(find.text('Contact Us'));
    await tester.tap(find.text('Contact Us'));
    await tester.pumpAndSettle();
    await preview(tester, 'contact');
    await tester.ensureVisible(find.text('FAQ'));
    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();
    expect(find.byType(CompanyFaqScreen), findsOneWidget);
    await preview(tester, 'faq');
    await tester.tap(find.text('Go to Homepage'));
    await tester.pumpAndSettle();
    expect(homeCalls, 1);
    expect(find.byType(CompanyProfileScreen), findsOneWidget);
    expect(find.byType(CompanyFaqScreen), findsNothing);
  });

  testWidgets('change password page validates confirmation before saving', (
    tester,
  ) async {
    var saves = 0;
    await mount(
      tester,
      CompanyChangePasswordScreen(
        onSavePassword: (_, _) async {
          saves++;
        },
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'OldPassword123');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPassword123');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'DifferentPassword123',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(find.text('Save Password'));
    await tester.tap(find.text('Save Password'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    await preview(tester, 'change-password');
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('logout revokes session and clears navigation to login', (
    tester,
  ) async {
    final previous = ApiClient.dio.httpClientAdapter;
    var logouts = 0;
    ApiClient.dio.httpClientAdapter = Adapter((request) {
      expect(request.path, 'auth/logout');
      expect(request.headers['Authorization'], 'Bearer test-session');
      logouts++;
      return response({'success': true});
    });
    addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
    await mount(
      tester,
      CompanyProfileScreen(onGoHomepage: () {}, profileStore: FakeStore()),
    );
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(logouts, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CompanyProfileScreen), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    expect(prefs.getString('user_role'), isNull);
  });
}
