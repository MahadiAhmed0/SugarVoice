// lib/Intro/language_selection_page.dart
import 'package:flutter/material.dart';
import '../Authentication/login_page.dart';
import '../Utils/voice_utils.dart'; // Import your voice_utils

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key}); // Added const constructor

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  @override
  void initState() {
    super.initState();
    initTts(); // Initialize TTS when the page is created
    // Speak a general greeting when the page loads, perhaps in a default language.
    // Or, you can wait for user language selection to speak.
    // For now, let's speak upon selection.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                speakText(
                  'সুপ্রভাত, আপা! আপনি কি আপনার ওষুধ খেয়েছেন?', // Bangla text
                  languageCode: 'bn-BD', // Specify Bangla language code
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('বাংলা'), // Changed to const
            ),
            ElevatedButton(
              onPressed: () {
                speakText(
                  'Good morning, Apa! Did you take your medicine?', // English text
                  languageCode: 'en-US', // Specify English language code
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('English'), // Changed to const
            ),
          ],
        ),
      ),
    );
  }
}