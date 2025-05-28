// lib/main.dart
import 'package:application_for_diabetic_patients/Home/MedicineLogPage.dart';
import 'package:flutter/material.dart';
import 'Intro/language_selection_page.dart';

import 'Updated_Home/journal_entry.dart';
import 'Updated_Home/Homepage.dart';

import 'Updated_Home/medicine_tracker.dart';
import 'Utils/voice_utils.dart'; // Import voice_utils

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized
  await initTts(); // Initialize TTS before running the app

  // Determine the greeting based on the current time
  String greeting = '';
  String languageCode = 'bn-BD'; // Default to Bangla

  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    greeting = 'সুপ্রভাত, আপা! আপনি কি আপনার ওষুধ খেয়েছেন?'; // Good morning, Apa! Did you take your medicine?
  } else if (hour >= 12 && hour < 17) {
    greeting = 'শুভ বিকাল, আপা! আপনি কি আপনার ওষুধ খেয়েছেন?'; // Good afternoon, Apa! Did you take your medicine?
  } else if (hour >= 17 && hour < 20) {
    greeting = 'শুভ সন্ধ্যা, আপা! আপনি কি আপনার ওষুধ খেয়েছেন?'; // Good evening, Apa! Did you take your medicine?
  } else {
    greeting = 'শুভ রাত্রি, আপা! আপনি কি আপনার ওষুধ খেয়েছেন?'; // Good night, Apa! Did you take your medicine?
  }

  // You can also add English alternatives and select based on a stored preference
  // For simplicity, we'll keep it Bangla for now as requested.

  // Speak the greeting
  await speakText(greeting, languageCode: languageCode);

  runApp(const HomePageApp()); // Run your main app widget
}

class DiabetesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes App',
      debugShowCheckedModeBanner: false,
      home: LanguageSelectionPage(),
    );
  }
}