import 'package:flutter_tts/flutter_tts.dart';

class MoodSuggestions {
  static final _suggestions = {
    'sad': 'Take a deep breath. Everything will be okay.',
    'anxious': 'Try a 2-minute breathing exercise.',
    'tired': 'Take a short walk or rest your eyes for 5 minutes.'
  };

  static void suggest(String mood) {
    final tts = FlutterTts();
    final suggestion = _suggestions[mood];
    if (suggestion != null) {
      tts.speak(suggestion);
    } else {
      tts.speak("Stay positive and take care of yourself.");
    }
  }
}