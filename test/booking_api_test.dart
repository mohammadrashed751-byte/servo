import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/feature/user_account/home/presentation/screen/booking/book_screen.dart';
import 'package:servo/feature/user_account/home/presentation/screen/booking/booking_success_screen.dart';
import 'package:servo/feature/user_account/home/presentation/widgets/booking_time_picker.dart';

class BookingApi extends MarketplaceApi {
  final requests = <JsonMap>[];
  bool fail = true;
  @override
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    JsonMap? query,
  }) async {
    expect(path, 'bookings');
    expect(method, 'POST');
    requests.add(Map<String, dynamic>.from(data! as Map));
    if (fail) throw const ApiFailure('Booking rejected');
    return {'id': 91, 'status': 'pending'};
  }
}

void main() {
  testWidgets(
    'booking errors stay on form; retries reuse keys only for unchanged payloads',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = BookingApi();
      await tester.pumpWidget(
        MaterialApp(home: BookScreen(serviceId: 17, api: api)),
      );
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .onDateChanged(DateTime.now().add(const Duration(days: 2)));
      tester
          .widget<BookingTimePicker>(find.byType(BookingTimePicker))
          .onTimeChanged('01:00 PM');
      tester.widget<Checkbox>(find.byType(Checkbox)).onChanged!(true);
      await tester.pump();
      Future<void> submit() async {
        final button = find.widgetWithText(FilledButton, 'Booking');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      await submit();
      expect(find.byType(BookingSuccessScreen), findsNothing);
      expect(find.text('Booking rejected'), findsOneWidget);
      expect(api.requests.single['scheduled_time'], '13:00');
      expect(api.requests.single['service_id'], 17);
      await submit();
      expect(
        api.requests[0]['idempotency_key'],
        api.requests[1]['idempotency_key'],
      );
      tester
          .widget<BookingTimePicker>(find.byType(BookingTimePicker))
          .onTimeChanged('02:00 PM');
      await tester.pump();
      api.fail = false;
      await submit();
      expect(
        api.requests[2]['idempotency_key'],
        isNot(api.requests[1]['idempotency_key']),
      );
      expect(api.requests[2]['scheduled_time'], '14:00');
      expect(find.byType(BookingSuccessScreen), findsOneWidget);
    },
  );
}
