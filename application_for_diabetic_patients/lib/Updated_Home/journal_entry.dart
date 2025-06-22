import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'package:intl/intl.dart'; // Required for date formatting

// Import gamification managers
import 'package:application_for_diabetic_patients/Updated_Home/achievement_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mission_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/streak_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/xp_tracker.dart';

// --- JournalEntry Model ---
/// Represents a single journal entry.
/// Includes the actual thought, a timestamp, and a unique ID for deletion.
class JournalEntry {
  final String id; // Added missing 'id' for consistency and deletion
  final String username; // Added missing 'username'
  final String title; // Added missing 'title'
  final String content; // Changed 'thought' to 'content' for consistency
  final String timestamp; // Stored as ISO 8601 string


  JournalEntry({
    required this.id,
    required this.username,
    required this.title,
    required this.content,
    required this.timestamp,
  });
  /// Factory constructor to create a [JournalEntry] from a JSON map.
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String, // Parse id
      username: json['username'] as String, // Parse username
      title: json['title'] as String, // Parse title
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Converts a [JournalEntry] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in toJson
      'username': username, // Include username
      'title': title, // Include title
      'content': content,
      'timestamp': timestamp,
    };
  }

  /// Returns a human-readable formatted timestamp.
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
// --- End JournalEntry Model ---

/// The main application widget for the Daily Journal.
class DailyJournalApp extends StatelessWidget {
  const DailyJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Journal',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // A nice purple theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // fontFamily: 'Inter', // Keeping the 'Inter' font - ensure you have this font loaded if uncommenting

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade700, // Darker purple for buttons
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
          ),
        ),
        // FIX: Use CardThemeData instead of CardTheme for the theme property
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.deepPurple.shade50, // Light purple fill for input
          prefixIconColor: Colors.deepPurple,
          labelStyle: const TextStyle(color: Colors.deepPurple),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
      home: const JournalEntryScreen(),
    );
  }
}

/// The main screen for entering and viewing journal entries.
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});
  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final String _username = "Default User"; // Added username constant

  List<JournalEntry> _journalEntries = []; // List to store all journal entries
  late SharedPreferences _prefs; // Declare SharedPreferences instance

  @override
  void initState() {
    super.initState();
    _initSharedPreferences(); // Initialize and load entries
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  // --- SharedPreferences Initialization & CRUD Operations ---

  /// Initializes SharedPreferences and then loads existing journal entries.
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadJournalEntries();
  }

  /// Reads: Loads journal entries from local storage (SharedPreferences).
  Future<void> _loadJournalEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('journalEntries');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _journalEntries = jsonList.map((json) => JournalEntry.fromJson(json)).toList();
          // Ensure entries are sorted by latest timestamp first upon loading
          _journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('Error loading entries: $e');
      print('Error loading entries: $e'); // For debugging
    }
  }

  /// Creates: Saves a new journal entry to local storage.
  void _saveJournalEntry() async {
    if (_formKey.currentState!.validate()) {
      final newEntry = JournalEntry(
        id: DateTime.now().toIso8601String(), // Generate ID
        username: _username, // Use the username constant
        title: 'Daily Thought', // Default title for simplicity
        content: _thoughtController.text,
        timestamp: DateTime.now().toIso8601String(), // Automatic timestamp
      );
      setState(() {
        _journalEntries.add(newEntry); // Add new entry to the list
        _journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest first
      });
      await _persistJournalEntries(); // Persist the updated list to SharedPreferences
      _thoughtController.clear(); // Clear the input field after saving
      _showMessage('Your thought has been saved!');

      // Gamification: Award XP for logging a journal entry
      await XPTracker.addXP(15);
      await AchievementManager.unlock('Thoughtful Journaler'); // Example achievement
    }
  }

  /// Deletes: Removes a journal entry from local storage based on its ID.
  void _deleteJournalEntry(String id) {
    setState(() {
      _journalEntries.removeWhere((entry) => entry.id == id);
    });
    _persistJournalEntries(); // Persist the updated list
    _showMessage('Entry deleted.');
  }

  /// Helper to persist the current list of entries to local storage.
  Future<void> _persistJournalEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _journalEntries.map((entry) => entry.toJson()).toList();
      await _prefs.setString('journalEntries', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving entries: $e');
      print('Error saving entries: $e'); // For debugging
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
        title: const Text('My Daily Journal'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Input Form Section
            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _thoughtController,
                        maxLines: 5, // Allow multiple lines for journal entries
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'What\'s on your mind today?',
                          hintText: 'Write your thoughts here...',
                          prefixIcon: Icon(Icons.edit_note), // Journal icon
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please write your thoughts for the day.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _saveJournalEntry,
                        child: const Text('Add Entry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title for the entries list
            const Text(
              'Your Journal Entries:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30, thickness: 1, color: Colors.deepPurpleAccent),

            // Display Area for All Saved Entries
            Expanded(
              child: _journalEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No entries yet. Start journaling your thoughts!',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _journalEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _journalEntries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 3,
                          color: Colors.deepPurple.shade50, // Light purple card background
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.formattedTimestamp, // Display formatted date and time
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _deleteJournalEntry(entry.id); // Call delete function with entry ID
                                      },
                                      tooltip: 'Delete Entry',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.content, // Changed from .thought to .content
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
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