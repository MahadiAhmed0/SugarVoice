// lib/main.dart
import 'package:application_for_diabetic_patients/Home/MedicineLogPage.dart';
import 'package:flutter/material.dart';
import 'Intro/language_selection_page.dart';

import 'Updated_Home/journal_entry.dart';
import 'Updated_Home/Homepage.dart';

import 'Updated_Home/medicine_tracker.dart';
import 'Utils/voice_utils.dart';
// Import voice_utils

/*

TTS Data Installation: On some Android devices, the user might not have the required TTS voice data installed.
Go to your device's Settings.
Search for "Text-to-speech output" or "TTS settings" (exact path varies by manufacturer).
Ensure a preferred engine (like Google Text-to-speech Engine) is selected.
Check if voice data for Bangla (bn-BD) is installed.
If not, download it.
If you're testing on an emulator, ensure the emulator has Google Play Services and you're logged into a Google account, as the Google TTS engine often relies on this.
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized
  await initTts();
// Initialize TTS before running the app

  // Determine the greeting based on the current time
  String greeting = '';
  String languageCode = 'en-US'; // Already set to English [cite: 1]

  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    greeting = 'Good morning! Have you taken your medicine today?'; // More natural phrasing
  } else if (hour >= 12 && hour < 17) {
    greeting = 'Good afternoon! Have you taken your medicine today?'; // More natural phrasing
  } else if (hour >= 17 && hour < 20) {
    greeting = 'Good evening! Have you taken your medicine today?'; // More natural phrasing
  } else {
    greeting = 'Good night! Remember to take your medicine.'; // More natural phrasing
  }

  // Speak the greeting
  await speakText(greeting, languageCode: languageCode);

  runApp(const HomePageApp());
// Run your main app widget
}

class DiabetesApp extends StatelessWidget {
  const DiabetesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes App',
      debugShowCheckedModeBanner: false,
      home: LanguageSelectionPage(),
    );
  }
}