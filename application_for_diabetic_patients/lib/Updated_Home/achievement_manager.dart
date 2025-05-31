import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AchievementManager {
  static const _key = 'achievements';
  static Future<void> unlock(String achievement) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> achievements = prefs.getStringList(_key) ?? [];
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
      prefs.setStringList(_key, achievements);
      _speak("Achievement unlocked: $achievement");
    }
  }

  static Future<List<String>> getAchievements() async =>
    (await SharedPreferences.getInstance()).getStringList(_key) ?? [];
  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}