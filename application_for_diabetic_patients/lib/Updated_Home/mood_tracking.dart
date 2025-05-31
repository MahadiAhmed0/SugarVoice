import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

// Import gamification managers
import 'package:application_for_diabetic_patients/Updated_Home/achievement_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mission_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/streak_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/xp_tracker.dart';

// --- MoodEntry Model ---
class MoodEntry {
  final String id;
  final String username;
  final String mood;
  final String timestamp; // Stored as ISO 8601 string for easy parsing

  MoodEntry({
    required this.id,
    required this.username,
    required this.mood,
    required this.timestamp,
  });
  /// Factory constructor to create a [MoodEntry] from a JSON map.
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      username: json['username'] as String,
      mood: json['mood'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Converts a [MoodEntry] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'mood': mood,
      'timestamp': timestamp,
    };
  }

  /// Returns a human-readable formatted timestamp.
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
// --- End MoodEntry Model ---

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Or your preferred font
      ),
      home: const MoodTrackerHomePage(),
    );
  }
}

class MoodTrackerHomePage extends StatefulWidget {
  const MoodTrackerHomePage({super.key});

  @override
  State<MoodTrackerHomePage> createState() => _MoodTrackerHomePageState();
}

class _MoodTrackerHomePageState extends State<MoodTrackerHomePage> {
  final String _username = "FlutterUser"; // Hardcoded username
  String? _selectedMood;
  List<MoodEntry> _moodEntries = []; // Changed to store MoodEntry objects
  late SharedPreferences _prefs; // SharedPreferences instance

  final List<String> _moodCategories = [
    'Happy',
    'Sad',
    'Neutral',
    'Excited',
    'Anxious',
    'Stressed',
    'Calm',
    'Angry',
    'Tired',
    'Energetic'
  ];
  @override
  void initState() {
    super.initState();
    _initSharedPreferences(); // Initialize SharedPreferences and load data
  }

  // --- SharedPreferences Initialization & CRUD Operations ---

  /// Initializes SharedPreferences and then loads existing mood entries.
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMoodEntries();
  }

  /// Read: Loads mood entries from local storage (SharedPreferences).
  Future<void> _loadMoodEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('moodEntries');
      if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _moodEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
          // Sort by latest timestamp first upon loading
          _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('Error loading mood entries: $e');
      print('Error loading mood entries: $e'); // For debugging
    }
  }

  /// Create: Adds a new mood entry to local storage.
  void _addMoodEntry() async {
    if (_selectedMood == null || _selectedMood!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood.')),
      );
      return;
    }

    final newEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      username: _username,
      mood: _selectedMood!,
      timestamp: DateTime.now().toIso8601String(), // Automatic date and time as ISO string
    );
    setState(() {
      _moodEntries.insert(0, newEntry); // Add to the beginning
      _selectedMood = null; // Reset selected mood
    });
    await _persistMoodEntries(); // Persist the updated list
    _showMessage('Mood entry added successfully!');

    // Gamification: Award XP for logging mood
    await XPTracker.addXP(5);
    await StreakManager.logActivity('mood'); // Log mood activity for streak

    // Check for mission completion
    List<MoodEntry> allMoodEntries = [];
    final String? entriesJsonString = _prefs.getString('moodEntries');
    if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(entriesJsonString);
      allMoodEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
    }
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
    final moodLogsToday = allMoodEntries.where((entry) => DateFormat('yyyy-MM-dd').format(DateTime.parse(entry.timestamp)) == todayFormatted).length;

    final missions = await MissionManager.getMissions();
    for (int i = 0; i < missions.length; i++) {
      if (missions[i].contains('Track mood') && moodLogsToday >= int.parse(missions[i].replaceAll(RegExp(r'[^0-9]'), ''))) {
        await MissionManager.complete(i);
        await AchievementManager.unlock('Mood Tracker'); // Example achievement
      }
    }
  }

  /// Delete: Removes a mood entry from local storage based on its ID.
  void _deleteMoodEntry(String id) {
    setState(() {
      _moodEntries.removeWhere((entry) => entry.id == id);
    });
    _persistMoodEntries(); // Persist the updated list
    _showMessage('Mood entry deleted.');
  }

  /// Helper to persist the current list of entries to local storage.
  Future<void> _persistMoodEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _moodEntries.map((entry) => entry.toJson()).toList();
      await _prefs.setString('moodEntries', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving mood entries: $e');
      print('Error saving mood entries: $e'); // For debugging
    }
  }

  /// Helper function to show a simple message using a SnackBar.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display hardcoded username
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Logged in as: $_username',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Mood selection dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'How are you feeling today?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              value: _selectedMood,
              hint: const Text('Select your mood'),
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

            // Add Mood button
            ElevatedButton.icon(
              onPressed: _addMoodEntry,
              icon: const Icon(Icons.add_reaction),
              label: const Text(
                'Add Mood Entry',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Mood History section
            const Text(
              'Your Mood History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 20, thickness: 2, color: Colors.deepPurpleAccent),
            Expanded(
              child: _moodEntries.isEmpty
                  ? const Center(
                      child: Text(
                        'No mood entries yet. Add one above!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _moodEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _moodEntries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row( // Use Row to place text and delete icon
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mood: ${entry.mood}',
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Recorded: ${entry.formattedTimestamp}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'User: ${entry.username}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteMoodEntry(entry.id); // Call delete function with entry ID
                                  },
                                  tooltip: 'Delete Mood Entry',
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