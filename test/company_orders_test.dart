import 'api_test_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/widgets/company_chat_screen.dart';

import 'package:servo/feature/company_account/home/presentation/screen/company_service_details_screen.dart';
import 'package:servo/feature/company_account/home/presentation/screen/company_orders_screen.dart';

void main() {
  testWidgets(
    'Orders opens, acceptance persists, and opens existing company chat',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await fixtureController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: CompanyServiceDetailsScreen(
            service: controller.services.first,
            controller: controller,
          ),
        ),
      );
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.byType(CompanyOrdersScreen), findsOneWidget);
      expect(find.text('MOHAMMED'), findsNWidgets(4));
      await tester.tap(find.byTooltip('Accept order').first);
      await tester.pumpAndSettle();
      expect(controller.ordersFor('122').first.accepted, isTrue);
      expect(find.byTooltip('Open chat'), findsOneWidget);
      await tester.tap(find.byTooltip('Open chat'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CompanyChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('services without orders show an empty state', (tester) async {
    final controller = await fixtureController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CompanyOrdersScreen(serviceId: '123', controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No orders yet'), findsOneWidget);
    expect(controller.ordersFor('123'), isEmpty);
  });
}
