// bangla_language_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class BanglaLanguageManager {
  static const _languageKey = 'app_language';

  static Future<bool> isBangla() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) == 'bn';
  }

  static Future<void> setBangla(bool isBangla) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, isBangla ? 'bn' : 'en');
  }

  static Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await isBangla();
    await prefs.setString(_languageKey, current ? 'en' : 'bn');
  }
}