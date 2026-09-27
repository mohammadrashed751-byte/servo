import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The test double deliberately allows changing failures between save attempts.
// ignore: must_be_immutable
class TestProfilePreferences extends Fake implements SharedPreferencesAsync {
  final Map<String, String> values = {};
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;

  @override
  Future<String?> getString(String key) async {
    if (failRead) throw StateError('Read failed');
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    if (failWrite) throw StateError('Write failed');
    writes++;
    values[key] = value;
  }
}
