import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileLocalStore {
  ProfileLocalStore({this.preferences});

  static const _storageKey = 'servo.profile.v1';

  final SharedPreferencesAsync? preferences;
  late final SharedPreferencesAsync _prefs =
      preferences ?? SharedPreferencesAsync();

  Future<UserProfile> load() async {
    final saved = await _prefs.getString(_storageKey);
    if (saved == null) return UserProfile.initial;
    final decoded = jsonDecode(saved);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved profile');
    }
    return UserProfile.fromJson(decoded);
  }

  Future<void> save(UserProfile profile) =>
      _prefs.setString(_storageKey, jsonEncode(profile.toJson()));
}
