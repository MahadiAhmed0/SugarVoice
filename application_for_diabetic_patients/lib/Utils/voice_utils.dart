// lib/Utils/voice_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts

// Global instance for FlutterTts
FlutterTts flutterTts = FlutterTts();
bool _ttsInitialized = false;

// Initialize TTS with desired settings
Future<void> initTts() async {
  if (_ttsInitialized) return; // Prevent re-initialization

  // Set default language to Bangla (Bangladesh)
  // You might want to dynamically set this based on user's language preference
  await flutterTts.setLanguage('bn-BD'); // Common code for Bangla (Bangladesh)
  await flutterTts.setSpeechRate(0.5); // Adjust speed (e.g., 0.5 to 1.0)
  await flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
  await flutterTts.setPitch(0.5); // Set pitch (0.5 to 2.0)

  // Optional: Set platform-specific audio categories for iOS
  // This helps ensure audio plays correctly even if other audio is playing
  if (ThemeData().platform == TargetPlatform.iOS) {
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  // Set completion handler to know when speech is done
  flutterTts.setCompletionHandler(() {
    print("Speech completed");
  });

  // Set error handler
  flutterTts.setErrorHandler((message) {
    print("TTS Error: $message");
  });

  _ttsInitialized = true;
  print("TTS Initialized successfully.");
}

// Function to speak text
Future<void> speakText(String text, {String? languageCode}) async {
  if (!_ttsInitialized) {
    await initTts(); // Ensure TTS is initialized before speaking
  }
  if (languageCode != null) {
    await flutterTts.setLanguage(languageCode);
  }
  await flutterTts.speak(text);
}

// Existing showVoiceInputDialog function (no changes needed)
void showVoiceInputDialog({
  required BuildContext context,
  required Color borderColor,
  String title = 'Voice Input',
  String content = 'Speak now',
  String? snackbarText,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        IconButton(
          icon: Icon(Icons.mic, color: borderColor),
          onPressed: () {
            Navigator.pop(context);
            if (snackbarText != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(snackbarText)),
              );
            }
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    ),
  );
}