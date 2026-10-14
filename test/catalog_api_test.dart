import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/api_client.dart';
import 'package:servo/feature/user_account/home/domain/entities/filter_criteria.dart';
import 'package:servo/feature/user_account/home/presentation/screen/it_services.dart';
import 'api_integration_test.dart' show FakeAdapter, reply;

void main() {
  testWidgets(
    'category-only filter does not silently exclude expensive services',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final previous = ApiClient.dio.httpClientAdapter;
      addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
      var servicesRequested = false;
      ApiClient.dio.httpClientAdapter = FakeAdapter((request) {
        if (request.path == 'categories') {
          return reply([
            {'id': 9, 'name': 'Training'},
          ]);
        }
        expect(request.path, 'services');
        servicesRequested = true;
        expect(request.queryParameters['category_id'], 9);
        expect(request.queryParameters.containsKey('price_max'), isFalse);
        expect(request.queryParameters.containsKey('price_min'), isFalse);
        return reply([]);
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: ItServices(filters: FilterCriteria(category: 'Training')),
        ),
      );
      await tester.pumpAndSettle();
      expect(servicesRequested, isTrue);
      expect(find.text('No services found'), findsOneWidget);
    },
  );
}
