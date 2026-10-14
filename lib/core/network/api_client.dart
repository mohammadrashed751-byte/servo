import 'package:dio/dio.dart';

import '../local_storage.dart' show LocalStorage;

class ApiClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'https://services.alshalabiapps.com/api/v1/',
            ),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Accept-Language': 'en',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (options.uri.path.endsWith('/auth/password/forgot') ||
                  options.uri.path.endsWith('/auth/password/reset')) {
                options.headers.remove('Authorization');
                return handler.next(options);
              }
              final token = await LocalStorage.getToken();
              options.headers.remove('Authorization');
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
          ),
        );
}
