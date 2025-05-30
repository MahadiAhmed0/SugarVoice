// 📁 lib/Updated_Home/mission_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MissionManager {
  static const _weeklyKey = 'weekly_mission';
  static const _lastResetKey = 'mission_reset';
  static final _missions = [
    'Log glucose 4 times',
    'Track mood 3 times',
    'Log 5 meals'
  ];

  static Future<List<String>> getMissions() async => _missions;

  static Future<void> resetWeeklyMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    prefs.setString(_lastResetKey, now.toIso8601String());
    prefs.setStringList(_weeklyKey, List.filled(_missions.length, '0'));
  }

  static Future<void> complete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> status = prefs.getStringList(_weeklyKey) ?? List.filled(_missions.length, '0');
    status[index] = '1';
    prefs.setStringList(_weeklyKey, status);
    _speak("Weekly mission completed: ${_missions[index]}");
  }

  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}
