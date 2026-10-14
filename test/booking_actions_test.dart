import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/widgets/booking_actions_menu.dart';
import 'api_integration_test.dart' show apiWith, reply;

void main() {
  testWidgets(
    'cancel requires confirmation and failure never refreshes as success',
    (tester) async {
      var requests = 0;
      var refreshed = 0;
      final api = apiWith((request) {
        requests++;
        expect(request.path, 'bookings/17/cancel');
        expect(request.method, 'POST');
        expect(request.data, {'reason': 'Schedule changed'});
        return reply(null, success: false);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookingActionsMenu(
              id: '17',
              status: 'pending',
              api: api,
              onChanged: () async {
                refreshed++;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Booking actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel booking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep booking'));
      await tester.pumpAndSettle();
      expect(requests, 0);
      await tester.tap(find.byTooltip('Booking actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel booking'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Schedule changed');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(refreshed, 0);
      expect(find.text('Request rejected'), findsOneWidget);
    },
  );
}
