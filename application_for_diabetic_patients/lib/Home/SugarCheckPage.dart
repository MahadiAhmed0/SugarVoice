import 'package:flutter/material.dart';
import '../Utils/voice_utils.dart';
class CheckSugarPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Sugar Level'),
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
            Text(
              'Enter your current sugar level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sugar Level (mg/dL)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic, color: borderColor),
                  onPressed: () {
                    showVoiceInputDialog(
                      context: context,
                      borderColor: borderColor,
                      content: 'Speak your sugar level',
                      snackbarText: 'Listening for sugar level...',
                    );
                  },
                ),            
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                // Save sugar level
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            SizedBox(height: 20),
            Text(
              'Or take a photo of your glucometer',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            IconButton(
              icon: Icon(Icons.camera_alt, size: 50),
              onPressed: () {
                // Open camera to capture glucometer reading
              },
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
