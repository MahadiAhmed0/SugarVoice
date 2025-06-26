// meal_tracking_bangla.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'updated_achievement_manager_bangla.dart';
import 'updated_mission_manager_bangla.dart';
import 'updated_streak_manager_bangla.dart';
import 'xp_tracker_bangla.dart';

class MealEntryBangla {
  final String id;
  final String mealDescription;
  final String timestamp;
  final String username;

  MealEntryBangla({
    required this.id,
    required this.mealDescription,
    required this.timestamp,
    required this.username,
  });

  factory MealEntryBangla.fromJson(Map<String, dynamic> json) {
    return MealEntryBangla(
      id: json['id'] as String,
      mealDescription: json['mealDescription'] as String,
      timestamp: json['timestamp'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealDescription': mealDescription,
      'timestamp': timestamp,
      'username': username,
    };
  }

  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM dd,EEEE - hh:mm a').format(dateTime);
  }
}

class MealTrackerBangla extends StatelessWidget {
  const MealTrackerBangla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'খাবার ট্র্যাকার',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kalpurush',
      ),
      home: const MealTrackerBanglaHomePage(),
    );
  }
}

class MealTrackerBanglaHomePage extends StatefulWidget {
  const MealTrackerBanglaHomePage({super.key});

  @override
  State<MealTrackerBanglaHomePage> createState() => _MealTrackerBanglaHomePageState();
}

class _MealTrackerBanglaHomePageState extends State<MealTrackerBanglaHomePage> {
  final String _username = "ব্যবহারকারী";
  final List<String> _mealTypes = [
    "সকালের নাস্তা",
    "দুপুরের খাবার",
    "রাতের খাবার",
    "স্ন্যাক্স",
    "অন্যান্য"
  ];
  String? _selectedMealType;
  final TextEditingController _mealController = TextEditingController();
  List<MealEntryBangla> _trackedMeals = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _mealTypes[0];
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _mealController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMealEntries();
  }

  Future<void> _loadMealEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('mealEntriesBangla');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _trackedMeals = jsonList.map((json) => MealEntryBangla.fromJson(json)).toList();
          _trackedMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('খাবার এন্ট্রি লোড করতে ত্রুটি: $e');
    }
  }

  void _saveMealEntry() async {
    if (_mealController.text.isNotEmpty && _selectedMealType != null) {
      final newEntry = MealEntryBangla(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _username,
        mealDescription: '$_selectedMealType: ${_mealController.text}',
        timestamp: DateTime.now().toIso8601String(),
      );
      
      setState(() {
        _trackedMeals.add(newEntry);
        _trackedMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
      
      await _persistMealEntries();
      _mealController.clear();
      _showMessage('খাবার সংরক্ষণ করা হয়েছে');

      await XPTracker.addXP(10);
      await StreakManager.logActivity('meal');
    } else {
      _showMessage('খাবার এবং খাবারের ধরন নির্বাচন করুন');
    }
  }

  void _deleteMealEntry(String id) {
    setState(() {
      _trackedMeals.removeWhere((entry) => entry.id == id);
    });
    _persistMealEntries();
    _showMessage('খাবার এন্ট্রি মুছে ফেলা হয়েছে');
  }

  Future<void> _persistMealEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _trackedMeals.map((entry) => entry.toJson()).toList();
      await _prefs.setString('mealEntriesBangla', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('খাবার এন্ট্রি সংরক্ষণ করতে ত্রুটি: $e');
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
        title: const Text('খাবার ট্র্যাকার'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            DropdownButton<String>(
              value: _selectedMealType,
              items: _mealTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMealType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mealController,
              decoration: const InputDecoration(
                labelText: 'আপনি কী খেয়েছেন?',
                hintText: 'যেমন, ভাত, মাছ, ডাল',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMealEntry,
              child: const Text('খাবার যোগ করুন',
               style: TextStyle(
      fontSize: 16,
      color: Colors.blue,  )
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'আপনার খাবারের তালিকা',
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _trackedMeals.isEmpty
                  ? const Center(
                      child: Text('কোনো খাবার এন্ট্রি নেই'),
                    )
                  : ListView.builder(
                      itemCount: _trackedMeals.length,
                      itemBuilder: (context, index) {
                        final entry = _trackedMeals[index];
                        return Card(
                          child: ListTile(
                            title: Text(entry.mealDescription),
                            subtitle: Text(entry.formattedTimestamp),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMealEntry(entry.id),
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