// utils/voice_utils.dart
import 'package:flutter/material.dart';

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