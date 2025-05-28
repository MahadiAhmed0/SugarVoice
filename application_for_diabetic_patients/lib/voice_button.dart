import 'package:flutter/material.dart';
import 'speech_to_text_helper.dart';

class VoiceButton extends StatelessWidget {
  final SpeechToTextHelper speechHelper;
  final Function(String) onResult;
  final String localeId;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const VoiceButton({
    super.key,
    required this.speechHelper,
    required this.onResult,
    this.localeId = 'en_US',
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: speechHelper,
      builder: (context, isListening, child) {
        return IconButton(
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening ? activeColor : inactiveColor,
            size: size,
          ),
          onPressed: () {
            if (isListening) {
              speechHelper.stopListening();
            } else {
              speechHelper.startListening(
                onResult: onResult,
                localeId: localeId,
              );
            }
          },
          tooltip: 'Voice Input',
        );
      },
    );
  }
}