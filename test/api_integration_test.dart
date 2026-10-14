import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import 'package:servo/feature/company_account/home/presentation/controllers/company_services_controller.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody reply(
  dynamic data, {
  int status = 200,
  dynamic meta,
  bool success = true,
}) => ResponseBody.fromString(
  jsonEncode({
    'success': success,
    'data': data,
    'meta': meta,
    'message': 'Request rejected',
  }),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

MarketplaceApi apiWith(ResponseBody Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.invalid/v1/'));
  dio.httpClientAdapter = FakeAdapter(respond);
  return MarketplaceApi(client: dio);
}

void main() {
  test('public service fixture maps actual category ids, price and images', () {
    final body = jsonDecode(
      File('test/fixtures/services.json').readAsStringSync(),
    );
    final service = CompanyServicesController.parse(
      Map<String, dynamic>.from(body['data'][0]),
    );
    expect(service.id, '1');
    expect(service.categoryId, 1);
    expect(service.price, 500);
    expect(service.title, 'Website Development');
  });

  test('all pages are loaded from envelope pagination', () async {
    final seen = <int>[];
    final api = apiWith((request) {
      final page = request.queryParameters['page'] as int;
      seen.add(page);
      return reply(
        [
          {'id': page},
        ],
        meta: {
          'pagination': {'current_page': page, 'last_page': 2},
        },
      );
    });
    expect((await api.list('services')).length, 2);
    expect(seen, [1, 2]);
  });

  test(
    'provider mutations wait for server and failed delete preserves service',
    () async {
      final calls = <String>[];
      final service = <String, dynamic>{
        'id': 17,
        'title': 'Course',
        'price': 25,
        'is_active': true,
        'category': {'id': 8, 'name': 'Training'},
      };
      final api = apiWith((request) {
        calls.add('${request.method} ${request.path}');
        if (request.method == 'DELETE') {
          return reply(null, status: 403, success: false);
        }
        if (request.method == 'POST') {
          final payload = request.data as Map;
          expect(payload['category_id'], 8);
          expect(payload['title'], {'en': 'New course'});
          expect(payload.containsKey('id'), isFalse);
          expect(payload.containsKey('is_active'), isFalse);
          return reply(service, status: 201);
        }
        return switch (request.path) {
          'provider/services' => reply([service]),
          'categories' => reply([
            {'id': 8, 'name': 'Training'},
          ]),
          'me' => reply({'id': 10, 'name': 'Company'}),
          _ => throw StateError('Unexpected ${request.path}'),
        };
      });
      final controller = CompanyServicesController(api: api);
      addTearDown(controller.dispose);
      expect(controller.services, isEmpty);
      await controller.load();
      expect(controller.error, isNull);
      expect(controller.activeCount, 1);
      await expectLater(controller.delete('17'), throwsA(isA<ApiFailure>()));
      expect(controller.services.single.id, '17');
      await controller.add(
        controller.services.single.copyWith(title: 'New course'),
      );
      expect(calls, contains('POST provider/services'));
    },
  );

  test(
    'success false and malformed list cannot be treated as empty success',
    () async {
      await expectLater(
        apiWith((_) => reply([], success: false)).list('services'),
        throwsA(isA<ApiFailure>()),
      );
      await expectLater(
        apiWith((_) => reply('unexpected')).list('services'),
        throwsA(isA<ApiFailure>()),
      );
    },
  );

  testWidgets(
    'API loading failure is retryable and never displays sample records',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiContent<List<int>>(
              load: () async {
                if (attempts++ == 0) throw const ApiFailure('Offline');
                return [17];
              },
              builder: (_, values) => Text('Service ${values.single}'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Offline'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Service 17'), findsOneWidget);
    },
  );
}
