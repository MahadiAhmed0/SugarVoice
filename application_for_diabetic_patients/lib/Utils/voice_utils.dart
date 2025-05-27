import 'package:application_for_diabetic_patients/Home/CallFamilyPage.dart';
import 'package:application_for_diabetic_patients/Home/FoodAdvice.Dart';
import 'package:application_for_diabetic_patients/Home/MedicineLogPage.dart';
import 'package:application_for_diabetic_patients/Home/OfflineDiaryPage.dart';
import 'package:application_for_diabetic_patients/Home/SugarCheckPage.dart';
import 'package:application_for_diabetic_patients/speech_navigation.dart';
import 'package:flutter/material.dart';
import '/speech_navigation.dart';

Future<void> showVoiceInputDialog({
  required BuildContext context,
  required Color borderColor,
  String title = 'Voice Input',
  String content = 'Speak now',
  String? snackbarText,
}) async {
  final speechNav = SpeechNavigation();
  await speechNav.initSpeech();

  bool isListening = false;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        StatefulBuilder(
          builder: (context, setState) {
            return IconButton(
              icon: Icon(
                isListening ? Icons.stop : Icons.mic,
                color: borderColor,
              ),
              onPressed: () async {
                if (!isListening) {
                  setState(() => isListening = true);
                  if (snackbarText != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(snackbarText)),
                    );
                  }
                  
                  final command = await speechNav.listenForCommand();
                  final navCommand = speechNav.getNavigationCommand(command);
                  
                  if (navCommand != null && context.mounted) {
                    Navigator.pop(context); // Close dialog
                    
                    // Navigate based on command
                    switch (navCommand) {
                      case 'Check Sugar':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CheckSugarPage()));
                        break;
                      case 'Take/Log Medicine':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineLogPage()));
                        break;
                      case 'Food Advice':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FoodAdvicePage()));
                        break;
                      case 'Call Family':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CallFamilyPage()));
                        break;
                      case 'Offline Diary':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OfflineDiaryPage()));
                        break;
                    }
                  }
                } else {
                  setState(() => isListening = false);
                }
              },
            );
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