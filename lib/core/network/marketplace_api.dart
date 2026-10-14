import 'package:dio/dio.dart';
import 'api_client.dart';

typedef JsonMap = Map<String, dynamic>;

class ApiFailure implements Exception {
  const ApiFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class MarketplaceApi {
  MarketplaceApi({Dio? client}) : client = client ?? ApiClient.dio;
  final Dio client;

  Future<JsonMap> envelope(
    String path, {
    String method = 'GET',
    Object? data,
    JsonMap? query,
  }) async {
    try {
      final response = await client.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      final body = response.data;
      if (body is! JsonMap || body['success'] != true) {
        throw ApiFailure(
          body is Map
              ? (body['message']?.toString() ?? 'Request failed')
              : 'Invalid server response',
        );
      }
      return body;
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map) {
        final errors = body['errors'];
        final details = errors is Map
            ? errors.values.expand((v) => v is List ? v : [v]).join('\n')
            : '';
        throw ApiFailure(
          details.isNotEmpty
              ? details
              : body['message']?.toString() ?? 'Request failed',
        );
      }
      throw const ApiFailure(
        'Unable to connect. Check your connection and try again.',
      );
    }
  }

  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    JsonMap? query,
  }) async =>
      (await envelope(path, method: method, data: data, query: query))['data'];

  Future<List<JsonMap>> list(String path, {JsonMap? query}) async {
    final result = <JsonMap>[];
    var page = 1;
    while (true) {
      final body = await envelope(path, query: {...?query, 'page': page});
      final data = body['data'];
      if (data is! List) {
        throw const ApiFailure('Invalid list received from server');
      }
      result.addAll(
        data.map((e) {
          if (e is! JsonMap) {
            throw const ApiFailure('Invalid item received from server');
          }
          return e;
        }),
      );
      final meta = body['meta'];
      final pagination = meta is Map ? meta['pagination'] : null;
      final last = pagination is Map
          ? int.tryParse('${pagination['last_page']}') ?? 1
          : 1;
      if (page >= last) break;
      if (data.isEmpty || page >= 1000) {
        throw const ApiFailure('Unable to load all pages');
      }
      page++;
    }
    return result;
  }
}

String apiText(dynamic value) {
  if (value is Map) return (value['en'] ?? value['ar'] ?? '').toString();
  return value?.toString() ?? '';
}

JsonMap apiMap(dynamic value) => value is JsonMap ? value : <String, dynamic>{};
