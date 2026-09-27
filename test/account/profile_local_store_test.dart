import 'package:flutter_test/flutter_test.dart';
import 'package:servo/feature/account/data/datasources/profile_local_store.dart';
import 'package:servo/feature/account/data/models/user_profile.dart';

import '../support/profile_test_store.dart';

void main() {
  test(
    'Fresh install uses defaults; a new store reloads all saved fields',
    () async {
      final preferences = TestProfilePreferences();
      final store = ProfileLocalStore(preferences: preferences);
      expect((await store.load()).toJson(), UserProfile.initial.toJson());

      const edited = UserProfile(
        name: 'Ayman',
        email: 'ayman@example.com',
        phone: '0791234567',
        specialization: 'Design',
      );
      await store.save(edited);
      final reopened = ProfileLocalStore(preferences: preferences);
      expect((await reopened.load()).toJson(), edited.toJson());
      expect(preferences.values.length, 1);
    },
  );

  test('A failed write preserves the previous saved profile', () async {
    final preferences = TestProfilePreferences();
    final store = ProfileLocalStore(preferences: preferences);
    await store.save(UserProfile.initial);
    preferences.failWrite = true;
    await expectLater(
      store.save(
        const UserProfile(
          name: 'New name',
          email: 'new@example.com',
          phone: '0791234567',
          specialization: 'IT',
        ),
      ),
      throwsStateError,
    );
    expect((await store.load()).toJson(), UserProfile.initial.toJson());
  });

  test('Unreadable saved data is reported without overwriting it', () async {
    final preferences = TestProfilePreferences();
    final store = ProfileLocalStore(preferences: preferences);
    await store.save(UserProfile.initial);
    final key = preferences.values.keys.single;
    preferences.values[key] = '{broken';
    await expectLater(store.load(), throwsFormatException);
    expect(preferences.values[key], '{broken');
    preferences.values[key] = '{"name":123}';
    await expectLater(store.load(), throwsFormatException);
  });
}
