// 📁 lib/Updated_Home/mission_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class MissionManager {
  static const _weeklyKey = 'সাপ্তাহিক_মিশন';         // key বাংলা ব্যবহার করা হলো
  static const _lastResetKey = 'মিশন_রিসেট_সময়';     // key বাংলা ব্যবহার করা হলো
  static final _missions = [
    'গ্লুকোজ ৪ বার লগ করুন',
    'মনের অবস্থা ৩ বার ট্র্যাক করুন',
    '৫টি খাবার লগ করুন'
  ];

  /// মিশনগুলো নিয়ে আসে, সাপ্তাহিক রিসেট চেক করে
  static Future<List<String>> getMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_lastResetKey);
    final now = DateTime.now();

    // চেক করুন নতুন সপ্তাহ শুরু হয়েছে কি না শেষ রিসেটের পর থেকে
    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      // হিসাব করুন শেষ রিসেট থেকে পরবর্তী সোমবার কতদিন পরে
      final daysUntilNextFromLastReset = (DateTime.monday - lastReset.weekday + 7) % 7;
      final nextFromLastReset = lastReset.add(Duration(days: daysUntilNextFromLastReset));

      // যদি এখন সময় পরবর্তী সোমবারের পরে হয় এবং আজ সোমবার হয়, তাহলে রিসেট দিন
      if (now.isAfter(nextFromLastReset) && now.weekday == DateTime.monday) {
        await resetMissions(); // নতুন সপ্তাহে মিশন রিসেট
      }
    } else {
      // যদি আগে কখনো রিসেট না করা হয়, তাহলে প্রথমবার রিসেট করুন
      await resetMissions();
    }
    return _missions;
  }

  /// মিশনের স্ট্যাটাস নিয়ে আসে (সম্পন্ন/অসম্পন্ন)
  static Future<List<String>> getMissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // নিশ্চিত করুন মিশনগুলো লোড হয়েছে স্ট্যাটাস নেওয়ার আগে
    await getMissions(); // এতে _weeklyKey আপডেট থাকে
    return prefs.getStringList(_weeklyKey) ?? List.filled(_missions.length, '0');
  }

  /// মিশন রিসেট করে, সব মিশনকে অসম্পন্ন ('0') করে সেট করে
  static Future<void> resetMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    prefs.setString(_lastResetKey, now.toIso8601String());
    // সব মিশনকে অসম্পন্ন চিহ্নিত করুন
    prefs.setStringList(_weeklyKey, List.filled(_missions.length, '0'));
  }

  /// নির্দিষ্ট মিশন সম্পন্ন হিসেবে চিহ্নিত করে
  static Future<void> complete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> status = prefs.getStringList(_weeklyKey) ?? List.filled(_missions.length, '0');
    if (index >= 0 && index < status.length && status[index] == '0') {
      status[index] = '1'; // সম্পন্ন হিসেবে চিহ্নিত
      prefs.setStringList(_weeklyKey, status);
      _speak("সাপ্তাহিক মিশন সম্পন্ন: ${_missions[index]}");
    }
  }

  /// টেক্সট টু স্পিচ (বাংলায় কথা বলার জন্য)
  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.setLanguage("bn-BD"); // বাংলা ভাষা সেট করুন
    await tts.speak(text);
  }
}
