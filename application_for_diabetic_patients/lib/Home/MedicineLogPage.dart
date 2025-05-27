import '../Utils/voice_utils.dart';
import 'MedicineDetails.dart';
import 'package:flutter/material.dart';
class MedicineLogPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Log'),
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
              'Did you take your medicine?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_circle, size: 50, color: Colors.green),
                      onPressed: () {
                        // Log medicine as taken
                        Navigator.pop(context);
                      },
                    ),
                    Text('Taken'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.access_time, size: 50, color: Colors.orange),
                      onPressed: () {
                        // Schedule reminder
                      },
                    ),
                    Text('Remind Later'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Or speak your medicine details:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
           IconButton(
  icon: Icon(Icons.mic, size: 50, color: borderColor),
  onPressed: () {
    showVoiceInputDialog(
      context: context,
      borderColor: borderColor,
      content: 'Speak your medicine details',
      snackbarText: 'Listening for medicine details...',
    );
  },
),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineDetailsPage()));
              },
              child: Text('Add Medicine Details'),
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