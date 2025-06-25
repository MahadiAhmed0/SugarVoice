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
      // First log, start streak
      streak = 1;
      _speak("আপনার $type স্ট্রিকের জন্য দুর্দান্ত শুরু!");
    } else {
      final lastLog = DateTime.parse(lastLogStr);
      final lastLogFormatted = formatter.format(lastLog);

      if (lastLogFormatted == todayStr) {
        // Already logged today, don't break or increase streak, just update timestamp
      } else {
        // Logged on a different day
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayFormatted = formatter.format(yesterday);

        if (lastLogFormatted == yesterdayFormatted) {
          // Logged yesterday, continue streak
          streak++;
          _speak("$type স্ট্রিক অব্যাহত! $streak দিন এবং গণনা চলছে।");
        } else {
          // Break in streak, reset
          streak = 1;
          _speak("আপনার $type স্ট্রিক আবার শুরু হয়েছে!");
        }
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