import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/feature/company_account/home/presentation/controllers/company_services_controller.dart';

class FixtureApi extends MarketplaceApi {
  final services = <JsonMap>[
    {
      'id': 122,
      'title': 'Web Development',
      'category': {'id': 1, 'name': 'IT Services'},
      'price': 150,
      'duration_min': 60,
      'is_active': false,
    },
    {
      'id': 123,
      'title': 'App Development',
      'category': {'id': 1, 'name': 'IT Services'},
      'price': 150,
      'duration_min': 60,
      'is_active': true,
    },
    {
      'id': 124,
      'title': 'UI Design',
      'category': {'id': 2, 'name': 'Design'},
      'price': 150,
      'duration_min': 60,
      'is_active': false,
    },
  ];
  final orders = List<JsonMap>.generate(
    4,
    (i) => {
      'id': i + 1,
      'status': 'pending',
      'customer': {'name': 'MOHAMMED', 'rating_avg': 4},
      'scheduled_date': '2024-10-27',
    },
  );
  @override
  Future<List<JsonMap>> list(String path, {JsonMap? query}) async {
    if (path == 'conversations/5/messages') return [];
    if (path == 'provider/services') return List.of(services);
    if (path == 'categories') {
      return [
        {'id': 1, 'name': 'IT Services'},
        {'id': 2, 'name': 'Design'},
      ];
    }
    if (path == 'provider/services/122/bookings') return List.of(orders);
    if (path == 'provider/services/123/bookings') return [];
    throw StateError('Unexpected GET $path');
  }

  @override
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    JsonMap? query,
  }) async {
    if (path == 'conversations') return {'id': 5};
    if (path == 'me') return {'id': 1, 'name': 'Company'};
    if (method == 'DELETE') {
      services.removeWhere((s) => path.endsWith('/${s['id']}'));
      return null;
    }
    if (method == 'PUT') {
      final payload = data as JsonMap;
      final index = services.indexWhere((s) => path.endsWith('/${s['id']}'));
      services[index] = {
        ...services[index],
        ...payload,
        'title': apiText(payload['title']),
        'category': {'id': payload['category_id'], 'name': 'IT Services'},
      };
      return services[index];
    }
    if (path.endsWith('/accept')) {
      orders[0] = {...orders[0], 'status': 'accepted'};
      return orders[0];
    }
    throw StateError('Unexpected $method $path');
  }
}

Future<CompanyServicesController> fixtureController() async {
  final controller = CompanyServicesController(api: FixtureApi());
  await controller.load();
  return controller;
}
