import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';
import '../model/reset_password_request_model.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(LoginRequestModel model) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/login',
        data: model.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      throw Exception('No internet connection');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequestModel model) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/register',
        data: model.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      throw Exception('No internet connection');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) => _accountRequest(
    'me/password',
    data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    },
  );

  Future<Map<String, dynamic>> getCurrentAccount() async {
    final response = await ApiClient.dio.get<dynamic>('me');

    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid account response');
    }

    if (body['success'] != true) {
      throw Exception('Unable to verify the account');
    }

    return body;
  }

  Future<Map<String, dynamic>> getProviderProfile() async {
    final response = await ApiClient.dio.get<dynamic>('provider/profile');

    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid provider profile response');
    }

    return body;
  }

  Future<void> logout() => _accountRequest('auth/logout');

  Future<void> _accountRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final logout = endpoint == 'auth/logout';
    try {
      final response = await ApiClient.dio.request<dynamic>(
        endpoint,
        data: data,
        options: Options(method: logout ? 'POST' : 'PUT'),
      );
      if (response.data is! Map || response.data['success'] != true) {
        throw const AccountAuthException(
          'The request was not completed. Please try again.',
        );
      }
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401) {
        if (logout) return;
        throw const AccountAuthException(
          'Your session has expired. Please log out and sign in again.',
        );
      }
      final body = error.response?.data;
      final errors = body is Map ? body['errors'] : null;
      if (status == 422 && errors is Map) {
        if (errors.containsKey('current_password')) {
          throw const AccountAuthException(
            'The current password is incorrect.',
          );
        }
        if (errors.containsKey('password_confirmation')) {
          throw const AccountAuthException('Passwords do not match.');
        }
        if (errors.containsKey('password')) {
          throw const AccountAuthException(
            'This password was not accepted. Choose a stronger password.',
          );
        }
      }
      throw AccountAuthException(
        status == 429
            ? 'Too many attempts. Please wait before trying again.'
            : 'Unable to complete the request. Check your connection and try again.',
      );
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) =>
      _passwordRequest('auth/password/forgot', {'email': email.trim()});

  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequestModel model) =>
      _passwordRequest('auth/password/reset', model.toJson());

  Future<Map<String, dynamic>> _passwordRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final resetting = endpoint.endsWith('/reset');
    try {
      final response = await ApiClient.dio.post<dynamic>(endpoint, data: data);
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const PasswordRecoveryException(
          'Unable to read the server response. Please try again later.',
        );
      }
      if (body['success'] != true) {
        throw PasswordRecoveryException(_recoveryError(body, resetting));
      }
      return body;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 429) {
        throw const PasswordRecoveryException(
          'Too many attempts. Please wait before trying again.',
        );
      }
      if (status == 422 || status == 400) {
        throw PasswordRecoveryException(
          _recoveryError(error.response?.data, resetting),
        );
      }
      if (status == 401 || status == 403 || status == 410) {
        throw PasswordRecoveryException(
          resetting
              ? 'This reset link is invalid or expired. Request a new link.'
              : 'Unable to send reset instructions. Please try again later.',
        );
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const PasswordRecoveryException(
          'The request timed out. Please try again.',
        );
      }
      if (error.type == DioExceptionType.connectionError) {
        throw const PasswordRecoveryException(
          'Check your internet connection and try again.',
        );
      }
      throw const PasswordRecoveryException(
        'Unable to complete the request. Please try again later.',
      );
    }
  }

  String _recoveryError(dynamic body, bool resetting) {
    final errors = body is Map ? body['errors'] : null;
    if (resetting && errors is Map) {
      if (errors.containsKey('token') || errors.containsKey('email')) {
        return 'This reset link is invalid or expired. Request a new link.';
      }
      if (errors.containsKey('password_confirmation')) {
        return 'Passwords do not match. Please confirm your new password.';
      }
      if (errors.containsKey('password')) {
        return 'This password was not accepted. Choose a stronger, unique password.';
      }
    }
    return resetting
        ? 'Unable to reset your password. The link may have expired or already been used. Request a new link and try again.'
        : 'Unable to send reset instructions. Check your email address and try again.';
  }
}

class PasswordRecoveryException implements Exception {
  const PasswordRecoveryException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AccountAuthException implements Exception {
  const AccountAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
