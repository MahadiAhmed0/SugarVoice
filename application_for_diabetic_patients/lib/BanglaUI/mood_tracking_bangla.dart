// mood_tracking_bangla.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'updated_achievement_manager_bangla.dart';
import 'updated_mission_manager_bangla.dart';
import 'updated_streak_manager_bangla.dart';
import 'xp_tracker_bangla.dart';

class MoodEntryBangla {
  final String id;
  final String username;
  final String mood;
  final String timestamp;

  MoodEntryBangla({
    required this.id,
    required this.username,
    required this.mood,
    required this.timestamp,
  });

  factory MoodEntryBangla.fromJson(Map<String, dynamic> json) {
    return MoodEntryBangla(
      id: json['id'] as String,
      username: json['username'] as String,
      mood: json['mood'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'mood': mood,
      'timestamp': timestamp,
    };
  }

  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  get mealDescription => null;
}

class MoodTrackerBangla extends StatelessWidget {
  const MoodTrackerBangla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'মুড ট্র্যাকার',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kalpurush',
      ),
      home: const MoodTrackerBanglaHomePage(),
    );
  }
}

class MoodTrackerBanglaHomePage extends StatefulWidget {
  const MoodTrackerBanglaHomePage({super.key});

  @override
  State<MoodTrackerBanglaHomePage> createState() => _MoodTrackerBanglaHomePageState();
}

class _MoodTrackerBanglaHomePageState extends State<MoodTrackerBanglaHomePage> {
  final String _username = "ব্যবহারকারী";
  String? _selectedMood;
  List<MoodEntryBangla> _moodEntries = [];
  late SharedPreferences _prefs;

  final List<String> _moodCategories = [
    'খুশি',
    'দুঃখিত',
    'স্বাভাবিক',
    'উত্তেজিত',
    'উদ্বিগ্ন',
    'চাপে',
    'শান্ত',
    'রাগান্বিত',
    'ক্লান্ত',
    'শক্তিশালী'
  ];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('moodEntriesBangla');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _moodEntries = jsonList.map((json) => MoodEntryBangla.fromJson(json)).toList();
          _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('মুড এন্ট্রি লোড করতে ত্রুটি: $e');
    }
  }

  void _addMoodEntry() async {
    if (_selectedMood == null) {
      _showMessage('একটি মুড নির্বাচন করুন');
      return;
    }

    final newEntry = MoodEntryBangla(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: _username,
      mood: _selectedMood!,
      timestamp: DateTime.now().toIso8601String(),
    );
    
    setState(() {
      _moodEntries.insert(0, newEntry);
      _selectedMood = null;
    });
    
    await _persistMoodEntries();
    _showMessage('মুড এন্ট্রি সংরক্ষণ করা হয়েছে!');

    await XPTracker.addXP(5);
    await StreakManager.logActivity('mood');
  }

  void _deleteMoodEntry(String id) {
    setState(() {
      _moodEntries.removeWhere((entry) => entry.id == id);
    });
    _persistMoodEntries();
    _showMessage('মুড এন্ট্রি মুছে ফেলা হয়েছে');
  }

  Future<void> _persistMoodEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _moodEntries.map((entry) => entry.toJson()).toList();
      await _prefs.setString('moodEntriesBangla', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('মুড এন্ট্রি সংরক্ষণ করতে ত্রুটি: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মুড ট্র্যাকার'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'আপনি আজ কেমন বোধ করছেন?',
              ),
              value: _selectedMood,
              hint: const Text('মুড নির্বাচন করুন'),
              items: _moodCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMood = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMoodEntry,
              child: const Text('মুড এন্ট্রি যোগ করুন',
               style: TextStyle(
      fontSize: 16,
      color: Colors.blue,  )
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'আপনার মুড হিস্ট্রি',
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _moodEntries.isEmpty
                  ? const Center(
                      child: Text('কোনো মুড এন্ট্রি নেই'),
                    )
                  : ListView.builder(
                      itemCount: _moodEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _moodEntries[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('মুড: ${entry.mood}'),
                                      Text('সময়: ${entry.formattedTimestamp}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMoodEntry(entry.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}