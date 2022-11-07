import 'package:shared_preferences/shared_preferences.dart';

class SharePreferencesStore {
  static void setPreference(prefs, bool? value) async {
    // Obtain shared preferences.
    // final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoLogin', value!);
  }

  static getPreferences(sharepreference, String value) async {
    final bool? isAutoLogin = sharepreference.getBool(value);
    return isAutoLogin;
  }
}
