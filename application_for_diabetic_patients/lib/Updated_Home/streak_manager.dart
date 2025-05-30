import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class StreakManager {
  static const _streakKeyPrefix = 'streak_';
  static const _lastLogKeyPrefix = 'lastlog_';

  static Future<void> logActivity(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastLogStr = prefs.getString(_lastLogKeyPrefix + type);
    final formatter = DateFormat('yyyy-MM-dd');
    final todayStr = formatter.format(now);

    int streak = prefs.getInt(_streakKeyPrefix + type) ?? 0;

    if (lastLogStr == null) {
      streak = 1;
      _speak("Great start to your $type streak!");
    } else {
      final lastLog = DateTime.parse(lastLogStr);
      final diff = now.difference(lastLog).inDays;
      if (diff == 1 || diff == 0) {
        streak++;
        _speak("$type streak continued! $streak days and counting.");
      } else if (diff <= 2) {
        streak++;
        _speak("You almost broke the streak! But you're still going: $streak days.");
      } else {
        streak = 1;
        _speak("Restarted your $type streak!");
      }
    }

    prefs.setString(_lastLogKeyPrefix + type, todayStr);
    prefs.setInt(_streakKeyPrefix + type, streak);
  }

  static Future<int> getStreak(String type) async =>
    (await SharedPreferences.getInstance()).getInt(_streakKeyPrefix + type) ?? 0;

  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}