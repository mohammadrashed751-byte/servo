import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'profile_local_store.dart';
import '../models/user_profile.dart';

class ProfileRemoteStore extends ProfileLocalStore {
  ProfileRemoteStore({MarketplaceApi? api}) : _api = api ?? MarketplaceApi();
  final MarketplaceApi _api;
  int? _id;
  bool pushEnabled = false;
  String get _key => 'servo.customer.$_id.specialization.v1';
  @override
  Future<UserProfile> load() async {
    final data = apiMap(await _api.request('me'));
    if (data['id'] == null) throw const ApiFailure('Invalid profile received');
    _id = data['id'] as int;
    pushEnabled = data['push_enabled'] == true;
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: apiText(data['name']),
      avatar: apiText(data['avatar']),
      email: apiText(data['email']),
      phone: apiText(data['phone']),
      specialization: prefs.getString(_key) ?? '',
    );
  }

  Future<void> setPushNotifications(bool enabled) async {
    await _api.request(
      'me/preferences',
      method: 'PUT',
      data: {'push_enabled': enabled},
    );
    pushEnabled = enabled;
  }

  @override
  Future<void> save(UserProfile profile) async {
    if (_id == null) await load();
    await _api.request(
      'me',
      method: 'PUT',
      data: {
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
      },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, profile.specialization);
  }
}
