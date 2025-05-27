import 'CallFamilyPage.dart';
import 'FoodAdvice.Dart';
import 'MedicineLogPage.dart';
import 'OfflineDiaryPage.dart';
import 'SugarCheckPage.dart';
import 'package:flutter/material.dart';
import '../Utils/voice_utils.dart';

class HomePage extends StatelessWidget {
  final List<String> buttons = [
    'Check Sugar',
    'Take/Log Medicine',
    'Food Advice',
    'Call Family',
    'Offline Diary'
  ];

  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: borderColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: buttons
                  .map((label) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            switch (label) {
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
                          },
                          child: Center(
                              child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: borderColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  // Voice command functionality
                  _showVoiceCommandDialog(context);
                },
                backgroundColor: borderColor,
                child: Icon(Icons.mic),
              ),
            ),
          ),
        ],
      ),
    );
  }

    void _showVoiceCommandDialog(BuildContext context) {
      showVoiceInputDialog(
        context: context,
        borderColor: borderColor,
        title: "Speak Now",
        content: "What would you like to do?",
        snackbarText: 'Listening for command...',
    );
  }
}


