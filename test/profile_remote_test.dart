import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/feature/user_account/account/data/datasources/profile_remote_store.dart';
import 'package:servo/feature/user_account/account/data/models/user_profile.dart';
import 'api_integration_test.dart' show apiWith, reply;

void main() {
  test(
    'profile updates use me and keep unsupported specialization local per account',
    () async {
      SharedPreferences.setMockInitialValues({});
      var accountId = 11;
      var fail = false;
      final api = apiWith((request) {
        if (request.method == 'GET') {
          return reply({
            'id': accountId,
            'name': 'Customer',
            'email': 'customer@example.test',
            'phone': '+962791234567',
            'avatar': '',
            'push_enabled': true,
          });
        }
        if (fail) return reply(null, success: false);
        if (request.path == 'me') {
          expect(request.data, {
            'name': 'Updated',
            'email': 'customer@example.test',
            'phone': '+962791234567',
          });
        } else {
          expect(request.path, 'me/preferences');
          expect(request.data, {'push_enabled': false});
        }
        return reply(null);
      });
      final store = ProfileRemoteStore(api: api);
      expect((await store.load()).specialization, isEmpty);
      expect(store.pushEnabled, isTrue);
      const profile = UserProfile(
        name: 'Updated',
        email: 'customer@example.test',
        phone: '+962791234567',
        specialization: 'IT',
      );
      fail = true;
      await expectLater(store.save(profile), throwsA(isA<ApiFailure>()));
      expect((await store.load()).specialization, isEmpty);
      fail = false;
      await store.save(profile);
      expect((await store.load()).specialization, 'IT');
      await store.setPushNotifications(false);
      expect(store.pushEnabled, isFalse);
      accountId = 12;
      expect(
        (await ProfileRemoteStore(api: api).load()).specialization,
        isEmpty,
      );
    },
  );
}
