import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class XPTracker {
  static const _xpKey = 'xp';
  static const _levelKey = 'level';
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int xp = prefs.getInt(_xpKey) ?? 0;
    int level = prefs.getInt(_levelKey) ?? 1;

    xp += amount;
    // Level up logic: each level requires level * 100 XP
    while (xp >= level * 100) {
      xp -= level * 100; // Subtract XP for the current level
      level++; // Increase level
      _speak("Congratulations! You've reached level $level");
    }

    prefs.setInt(_xpKey, xp);
    prefs.setInt(_levelKey, level);
  }

  static Future<int> getXP() async => (await SharedPreferences.getInstance()).getInt(_xpKey) ?? 0;
  static Future<int> getLevel() async => (await SharedPreferences.getInstance()).getInt(_levelKey) ?? 1;
  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}