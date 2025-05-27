import 'package:speech_to_text/speech_recognition_result.dart' as stt;

import 'CallFamilyPage.dart';
import 'FoodAdvice.Dart';
import 'MedicineLogPage.dart';
import 'OfflineDiaryPage.dart';
import 'SugarCheckPage.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  final Color borderColor = Color(0xFF4B0082);

  final List<String> buttons = [
    'Check Sugar',
    'Take/Log Medicine',
    'Food Advice',
    'Call Family',
    'Offline Diary'
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });

    if (result.finalResult) {
      _handleVoiceCommand(_wordsSpoken);
    }
  }

  void _handleVoiceCommand(String command) {
    final text = command.toLowerCase();
    
    if (text.contains('check sugar') || text.contains('sugar check') || text.contains('sugar')) {
      _navigateToPage('Check Sugar');
    } else if (text.contains('medicine') || text.contains('log medicine') || text.contains('take medicine')) {
      _navigateToPage('Take/Log Medicine');
    } else if (text.contains('food') || text.contains('advice') || text.contains('food advice')) {
      _navigateToPage('Food Advice');
    } else if (text.contains('call') || text.contains('family') || text.contains('call family')) {
      _navigateToPage('Call Family');
    } else if (text.contains('diary') || text.contains('offline') || text.contains('offline diary')) {
      _navigateToPage('Offline Diary');
    }
  }

  void _navigateToPage(String label) {
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
  }

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
                            _navigateToPage(label);
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
          if (_speechToText.isListening)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.red,
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Listening...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _wordsSpoken,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      if (_confidenceLevel > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechToText.isListening ? Icons.mic : Icons.mic_off,
          color: Colors.white,
        ),
        backgroundColor: borderColor,
      ),
    );
  }
}