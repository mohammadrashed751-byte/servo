import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servo/feature/user_account/account/data/datasources/profile_local_store.dart';
import 'package:servo/feature/user_account/account/presentation/screen/profile_screen.dart';

import 'support/profile_test_store.dart';

void main() {
  testWidgets('Profile displays stored data and toggles notifications', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          profileStore: ProfileLocalStore(
            preferences: TestProfilePreferences(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Mohammed'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(tester.takeException(), isNull);
  });
}
