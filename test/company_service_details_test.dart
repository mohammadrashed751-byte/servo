import 'api_test_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servo/feature/company_account/home/presentation/screen/company_services_screen.dart';

void main() {
  testWidgets(
    'edit retains identity; cancel delete preserves service; delete updates list',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await fixtureController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: CompanyServicesScreen(controller: controller)),
      );
      await tester.tap(find.text('Web Development'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Web Development'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Updated course',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.text('Updated course'), findsOneWidget);
      expect(controller.services.first.id, '122');
      expect(controller.services.first.title, 'Updated course');
      await tester.ensureVisible(find.text('Delete'));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller.services.length, 3);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(controller.services.length, 2);
      expect(find.text('Updated course'), findsNothing);
      expect(find.text('App Development'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
