import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/feature/account/data/datasources/profile_local_store.dart';
import 'package:servo/feature/account/data/models/user_profile.dart';
import 'package:servo/feature/account/presentation/screen/edit_profile_screen.dart';
import 'package:servo/main.dart';

import '../support/profile_test_store.dart';

void main() {
  late TestProfilePreferences preferences;

  setUp(() => preferences = TestProfilePreferences());

  Future<void> openProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(profileStore: ProfileLocalStore(preferences: preferences)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Saved changes update Profile, repopulate Edit, and reload in a fresh app',
    (tester) async {
      await openProfile(tester);
      await openEditor(tester);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ayman');
      await tester.enterText(fields.at(1), 'ayman@example.com');
      await tester.enterText(fields.at(2), '0791234567');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Design').last);
      await tester.pumpAndSettle();
      await save(tester);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('Ayman'), findsOneWidget);
      expect(find.text('ayman@example.com'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MyApp(profileStore: ProfileLocalStore(preferences: preferences)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayman'), findsOneWidget);
      await openEditor(tester);
      final inputs = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(inputs[0].controller!.text, 'Ayman');
      expect(inputs[1].controller!.text, 'ayman@example.com');
      expect(inputs[2].controller!.text, '0791234567');
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .initialValue,
        'Design',
      );
      expect(preferences.writes, 1);
    },
  );

  testWidgets('Back discards an unsaved edit', (tester) async {
    await openProfile(tester);
    await openEditor(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Unsaved name');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Mohammed'), findsOneWidget);
    expect(preferences.writes, 0);
    await openEditor(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      UserProfile.initial.name,
    );
  });

  testWidgets(
    'Save failure keeps the editor and entered text available for retry',
    (tester) async {
      await openProfile(tester);
      await openEditor(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Ayman');
      preferences.failWrite = true;
      await save(tester);
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(
        find.text('Unable to save changes. Please try again.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Ayman',
      );
      preferences.failWrite = false;
      await save(tester);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('Ayman'), findsOneWidget);
    },
  );

  testWidgets('Read failure offers retry without replacing stored data', (
    tester,
  ) async {
    preferences.failRead = true;
    await openProfile(tester);
    expect(find.text('Unable to load your profile.'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    preferences.failRead = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Mohammed'), findsOneWidget);
    expect(preferences.writes, 0);
  });
}
