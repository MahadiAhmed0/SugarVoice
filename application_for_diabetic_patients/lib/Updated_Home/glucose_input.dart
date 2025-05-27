import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:intl/intl.dart'; // Required for date formatting
import 'package:shared_preferences/shared_preferences.dart'; // Required for local storage
import 'dart:convert'; // Required for JSON encoding/decoding

// --- GlucoseEntry Model ---
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

  // Factory constructor to create a GlucoseEntry from a JSON map
  factory GlucoseEntry.fromJson(Map<String, dynamic> json) {
    return GlucoseEntry(
      username: json['username'] as String,
      glucoseValue: json['glucoseValue'] as String,
      timestamp: json['timestamp'] as String,
      id: json['id'] as String,
    );
  }

  // Convert a GlucoseEntry object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'glucoseValue': glucoseValue,
      'timestamp': timestamp,
      'id': id,
    };
  }

  // Helper for display
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
// --- End GlucoseEntry Model ---


class GlucoseTrackerApp extends StatelessWidget {
  const GlucoseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glucose Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as per instructions
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const GlucoseEntryScreen(),
    );
  }
}

class GlucoseEntryScreen extends StatefulWidget {
  const GlucoseEntryScreen({super.key});

  @override
  State<GlucoseEntryScreen> createState() => _GlucoseEntryScreenState();
}

class _GlucoseEntryScreenState extends State<GlucoseEntryScreen> {
  final TextEditingController _glucoseController = TextEditingController();
  final String _savedUsername = 'Default User'; // Username is now set directly in code
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  List<GlucoseEntry> _glucoseEntries = []; // List to store all glucose entries

  @override
  void initState() {
    super.initState();
    _loadGlucoseEntries(); // Load entries when the screen initializes
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  // --- CRUD Operations ---

  // Read: Load glucose entries from local storage
  Future<void> _loadGlucoseEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJsonString = prefs.getString('glucoseEntries');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _glucoseEntries = jsonList.map((json) => GlucoseEntry.fromJson(json)).toList();
        });
      }
    } catch (e) {
      _showMessage('Error loading entries: $e');
    }
  }

  // Create: Save a new glucose entry to local storage
  void _saveGlucoseEntry() {
    if (_formKey.currentState!.validate()) {
      final newEntry = GlucoseEntry(
        username: _savedUsername,
        glucoseValue: _glucoseController.text,
        timestamp: DateTime.now().toIso8601String(), // Store as ISO 8601 string
      );

      setState(() {
        _glucoseEntries.add(newEntry); // Add new entry to the list
        _glucoseEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest first
      });

      _persistGlucoseEntries(); // Persist the updated list
      _glucoseController.clear(); // Clear the input field after saving
      _showMessage('Entry saved for $_savedUsername: ${newEntry.glucoseValue} mg/dL');
    }
  }

  // Delete: Remove a glucose entry from local storage
  void _deleteGlucoseEntry(String id) {
    setState(() {
      _glucoseEntries.removeWhere((entry) => entry.id == id);
    });
    _persistGlucoseEntries(); // Persist the updated list
    _showMessage('Entry deleted.');
  }

  // Helper to persist the current list of entries to local storage
  Future<void> _persistGlucoseEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _glucoseEntries.map((entry) => entry.toJson()).toList();
      await prefs.setString('glucoseEntries', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving entries: $e');
    }
  }

  // Helper function to show a simple message (instead of alert)
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
        title: const Text('Glucose Tracker'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // Changed to Column to hold input and list
          children: <Widget>[
            // Input Form
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _glucoseController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: 'Glucose Value (mg/dL)',
                      hintText: 'e.g., 120',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      prefixIcon: const Icon(Icons.bloodtype, color: Colors.blue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a glucose value';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _saveGlucoseEntry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save Glucose Entry',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Display Area for All Saved Entries
            Expanded( // Use Expanded to make the ListView take available space
              child: _glucoseEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No glucose entries yet. Add one above!',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _glucoseEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _glucoseEntries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Username: ${entry.username}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Glucose: ${entry.glucoseValue} mg/dL',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Recorded at: ${entry.formattedTimestamp}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteGlucoseEntry(entry.id),
                                  tooltip: 'Delete Entry',
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
