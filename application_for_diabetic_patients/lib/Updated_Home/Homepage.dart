import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'package:intl/intl.dart'; // Required for date formatting

// Import the other tracking pages
import 'package:application_for_diabetic_patients/Updated_Home/glucose_input.dart';
import 'package:application_for_diabetic_patients/Updated_Home/journal_entry.dart';
import 'package:application_for_diabetic_patients/Updated_Home/meal_tracking.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mood_tracking.dart';


// --- MoodEntry Model (Adapted for SharedPreferences and common structure) ---
/// Represents a single mood entry.
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

// --- MealEntry Model (Adapted for SharedPreferences and common structure) ---
/// Represents a single meal entry.
class MealEntry {
  final String id;
  final String mealDescription;
  final String timestamp; // Stored as ISO 8601 string
  final String username; // Added username for consistency with other models

  MealEntry({
    required this.id,
    required this.mealDescription,
    required this.timestamp,
    required this.username,
  });

  /// Factory constructor to create a [MealEntry] from a JSON map.
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      mealDescription: json['mealDescription'] as String,
      timestamp: json['timestamp'] as String,
      username: json['username'] as String,
    );
  }

  /// Converts a [MealEntry] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealDescription': mealDescription,
      'timestamp': timestamp,
      'username': username,
    };
  }

  /// Returns a human-readable formatted timestamp.
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}

// --- GlucoseEntry Model (from glucose_input.dart, adapted for common structure) ---
/// Represents a single glucose reading entry.
class GlucoseEntry {
  final String username;
  final String glucoseValue;
  final String timestamp;
  final String id; // Unique ID for each entry, useful for deletion

  GlucoseEntry({
    required this.username,
    required this.glucoseValue,
    required this.timestamp,
    String? id, // Make id nullable for initial creation
  }) : id = id ?? DateTime.now().toIso8601String(); // Generate ID if not provided

  /// Factory constructor to create a [GlucoseEntry] from a JSON map.
  factory GlucoseEntry.fromJson(Map<String, dynamic> json) {
    return GlucoseEntry(
      username: json['username'] as String,
      glucoseValue: json['glucoseValue'] as String,
      timestamp: json['timestamp'] as String,
      id: json['id'] as String,
    );
  }

  /// Converts a [GlucoseEntry] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'glucoseValue': glucoseValue,
      'timestamp': timestamp,
      'id': id,
    };
  }

  /// Returns a human-readable formatted timestamp.
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
// --- End Models ---


/// The main application widget for the Health Dashboard.
class HomePageApp extends StatelessWidget {
  const HomePageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Dashboard',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Main theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardThemeData( // Using CardThemeData for theme definition
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// The HomePage screen displaying recent health records.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Hardcoded username as requested
  final String _username = "HealthUser";

  // Lists to store recent entries for each category
  List<MoodEntry> _recentMoodEntries = [];
  List<MealEntry> _recentMealEntries = [];
  List<GlucoseEntry> _recentGlucoseEntries = [];

  @override
  void initState() {
    super.initState();
    _loadRecentRecords(); // Load records when the page initializes
  }

  /// Loads recent records from SharedPreferences for Mood, Meal, and Glucose.
  /// Filters entries to only include those from the last 3 days.
  Future<void> _loadRecentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    // --- Load Mood Entries ---
    // The original mood_tracking.dart didn't use SharedPreferences.
    // This assumes a 'moodEntries' key will be used for persistence.
    final String? moodEntriesJsonString = prefs.getString('moodEntries');
    if (moodEntriesJsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(moodEntriesJsonString);
        List<MoodEntry> allMoodEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
        _recentMoodEntries = allMoodEntries
            .where((entry) => DateTime.parse(entry.timestamp).isAfter(threeDaysAgo))
            .toList();
        _recentMoodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest
      } catch (e) {
        print('Error decoding mood entries: $e');
      }
    }

    // --- Load Meal Entries ---
    final String? mealEntriesJsonString = prefs.getString('mealEntries');
    if (mealEntriesJsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(mealEntriesJsonString);
        List<MealEntry> allMealEntries = jsonList.map((json) => MealEntry.fromJson(json)).toList();
        _recentMealEntries = allMealEntries
            .where((entry) => DateTime.parse(entry.timestamp).isAfter(threeDaysAgo))
            .toList();
        _recentMealEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest
      } catch (e) {
        print('Error decoding meal entries: $e');
      }
    }

    // --- Load Glucose Entries ---
    final String? glucoseEntriesJsonString = prefs.getString('glucoseEntries');
    if (glucoseEntriesJsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(glucoseEntriesJsonString);
        List<GlucoseEntry> allGlucoseEntries = jsonList.map((json) => GlucoseEntry.fromJson(json)).toList();
        _recentGlucoseEntries = allGlucoseEntries
            .where((entry) => DateTime.parse(entry.timestamp).isAfter(threeDaysAgo))
            .toList();
        _recentGlucoseEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest
      } catch (e) {
        print('Error decoding glucose entries: $e');
      }
    }

    // Update the UI once all data is loaded and filtered
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Dashboard'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView( // Allows the entire content to scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Hello Username Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.deepPurple.shade100, // Light purple background for the greeting
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.waving_hand, size: 30, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(
                      'Hello, $_username!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mood Entries Section
            _buildSectionTitle('Recent Moods'),
            _recentMoodEntries.isEmpty
                ? _buildNoRecordsMessage('No mood entries in the last 3 days.')
                : ListView.builder(
                    shrinkWrap: true, // Makes ListView only take up needed space
                    physics: const NeverScrollableScrollPhysics(), // Disables ListView's own scrolling
                    itemCount: _recentMoodEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _recentMoodEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        color: Colors.blue.shade50, // Light blue for mood cards
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mood: ${entry.mood}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recorded: ${entry.formattedTimestamp}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),

            // Meal Entries Section
            _buildSectionTitle('Recent Meals'),
            _recentMealEntries.isEmpty
                ? _buildNoRecordsMessage('No meal entries in the last 3 days.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentMealEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _recentMealEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        color: Colors.teal.shade50, // Light teal for meal cards
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meal: ${entry.mealDescription}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recorded: ${entry.formattedTimestamp}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),

            // Glucose Entries Section
            _buildSectionTitle('Recent Glucose Readings'),
            _recentGlucoseEntries.isEmpty
                ? _buildNoRecordsMessage('No glucose entries in the last 3 days.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentGlucoseEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _recentGlucoseEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        color: Colors.blue.shade50, // Light blue for glucose cards
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Glucose: ${entry.glucoseValue} mg/dL',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recorded: ${entry.formattedTimestamp}',
                                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.bloodtype, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GlucoseEntryScreen()),
                );
              },
              tooltip: 'Glucose Tracker',
            ),
            IconButton(
              icon: const Icon(Icons.book, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalEntryScreen()),
                );
              },
              tooltip: 'Journal Entry',
            ),
            IconButton(
              icon: const Icon(Icons.restaurant, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealTrackerHomePage()),
                );
              },
              tooltip: 'Meal Tracker',
            ),
            IconButton(
              icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoodTrackerHomePage()),
                );
              },
              tooltip: 'Mood Tracker',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent section titles
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Divider(height: 20, thickness: 1, color: Colors.deepPurpleAccent),
        const SizedBox(height: 10),
      ],
    );
  }

  // Helper widget to display a message when no records are found in a section
  Widget _buildNoRecordsMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}