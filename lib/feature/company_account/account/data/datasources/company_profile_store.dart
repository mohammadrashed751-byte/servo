import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/api_client.dart';
import '../models/company_profile.dart';

class CompanyProfileStore {
  CompanyProfileStore({Dio? client}) : _client = client ?? ApiClient.dio;
  final Dio _client;
  String _specializationKey(int id) => 'servo.company.$id.specialization.v1';

  Future<CompanyProfile> load() async {
    final response = await _client.get<dynamic>('me');
    final body = _checkedBody(response.data);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid company profile');
    }
    final profile = CompanyProfile.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    return CompanyProfile.fromJson(
      data,
      specialization: prefs.getString(_specializationKey(profile.id)) ?? '',
    );
  }

  Future<void> save(CompanyProfile profile) async {
    if (profile.id <= 0) {
      throw StateError('Load the company profile before saving');
    }
    final response = await _client.put<dynamic>(
      'me',
      data: profile.toAccountUpdate(),
    );
    _checkedBody(response.data);

    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      _specializationKey(profile.id),
      profile.specialization,
    )) {
      throw StateError('Unable to save specialization');
    }
  }

  Future<void> setPushNotifications(bool enabled) async {
    final response = await _client.put<dynamic>(
      'me/preferences',
      data: {'push_enabled': enabled},
    );
    _checkedBody(response.data);
  }

  Map<String, dynamic> _checkedBody(dynamic body) {
    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw const FormatException('Account request was not completed');
    }
    return body;
  }
}
