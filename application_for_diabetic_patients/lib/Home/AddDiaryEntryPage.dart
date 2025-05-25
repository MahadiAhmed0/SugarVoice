import 'package:flutter/material.dart';
import '../Utils/voice_utils.dart';
class AddDiaryEntryPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Diary Entry'),
        backgroundColor: borderColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Today\'s note',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
  icon: Icon(Icons.mic, color: borderColor),
  onPressed: () {
    showVoiceInputDialog(
      context: context,
      borderColor: borderColor,
      content: 'Speak your diary entry',
      snackbarText: 'Listening for diary entry...',
    );
  },
),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                // Save diary entry
                Navigator.pop(context);
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () => showVoiceInputDialog(
    context: context,
    borderColor: borderColor,
    content: 'What would you like to do?',
  ),
  backgroundColor: borderColor,
  child: Icon(Icons.mic),
),
    );
  }
}