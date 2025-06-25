// 📁 lib/Updated_Home/mission_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class MissionManager {
  static const _weeklyKey = 'weekly_mission';
  static const _lastResetKey = 'mission_reset';
  static final _missions = [
    'Log glucose 4 times',
    'Track mood 3 times',
    'Log 5 meals'
  ];

  static Future<List<String>> getMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_lastResetKey);
    final now = DateTime.now();

    // Check if a new week has started since last reset
    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      // Check if it's a new week (e.g., সোমবার and current date is past last reset date's week)
      // We calculate the number of days until the next সোমবার from lastReset.
      // If the current day is past that, it's a new week.
      final daysUntilNextFromLastReset = (DateTime.monday - lastReset.weekday + 7) % 7;
      final nextFromLastReset = lastReset.add(Duration(days: daysUntilNextFromLastReset));

      if (now.isAfter(nextFromLastReset) && now.weekday == DateTime.monday) {
        await resetMissions(); // Reset if a new week has truly started
      }
    } else {
      // If never reset, set initial missions
      await resetMissions();
    }
    return _missions;
  }

  static Future<List<String>> getMissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure missions are loaded before getting status
    await getMissions(); // This ensures _weeklyKey is up-to-date
    return prefs.getStringList(_weeklyKey) ?? List.filled(_missions.length, '0');
  }

  static Future<void> resetMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    prefs.setString(_lastResetKey, now.toIso8601String());
    // Initialize all missions as incomplete ('0')
    prefs.setStringList(_weeklyKey, List.filled(_missions.length, '0'));
  }

  static Future<void> complete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> status = prefs.getStringList(_weeklyKey) ?? List.filled(_missions.length, '0');
    if (index >= 0 && index < status.length && status[index] == '0') {
      status[index] = '1'; // Mark as completed
      prefs.setStringList(_weeklyKey, status);
      _speak("সাপ্তাহিক মিশন সম্পন্ন: ${_missions[index]}");
    }
  }

  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}