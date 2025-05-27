import 'package:application_for_diabetic_patients/Home/AddDiaryEntryPage.dart';
import 'package:flutter/material.dart';
import '../Utils/voice_utils.dart';

class OfflineDiaryPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);
  final List<Map<String, String>> diaryEntries = [
    {'date': 'Today', 'entry': 'Sugar: 120 mg/dL, took medicine'},
    {'date': 'Yesterday', 'entry': 'Sugar: 140 mg/dL, forgot morning medicine'},
    {'date': '2 days ago', 'entry': 'Sugar: 110 mg/dL, ate healthy meals'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Diary'),
        backgroundColor: borderColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Health Diary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: diaryEntries.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(diaryEntries[index]['date']!),
                    subtitle: Text(diaryEntries[index]['entry']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddDiaryEntryPage()));
              },
              child: Text('Add New Entry'),
            ),
          ),
        ],
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
