import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

// This model is included for context and potential future use,
// even though we're primarily displaying raw JSON in this app.
class GlucoseEntry {
  final String username;
  final String glucoseValue;
  final String timestamp;
  final String id;

  GlucoseEntry({
    required this.username,
    required this.glucoseValue,
    required this.timestamp,
    String? id,
  }) : id = id ?? DateTime.now().toIso8601String();

  factory GlucoseEntry.fromJson(Map<String, dynamic> json) {
    return GlucoseEntry(
      username: json['username'] as String,
      glucoseValue: json['glucoseValue'] as String,
      timestamp: json['timestamp'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'glucoseValue': glucoseValue,
      'timestamp': timestamp,
      'id': id,
    };
  }
}

class GlucoseJsonViewerApp extends StatelessWidget {
  const GlucoseJsonViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glucose JSON Viewer',
      theme: ThemeData(
        primarySwatch: Colors.green, // A different color theme for distinction
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: const JsonDataViewerScreen(),
    );
  }
}

class JsonDataViewerScreen extends StatefulWidget {
  const JsonDataViewerScreen({super.key});

  @override
  State<JsonDataViewerScreen> createState() => _JsonDataViewerScreenState();
}

class _JsonDataViewerScreenState extends State<JsonDataViewerScreen> {
  String _jsonData = 'Loading data...';

  @override
  void initState() {
    super.initState();
    _loadJsonData(); // Load data when the screen initializes
  }

  // Loads the raw JSON string from shared_preferences
  Future<void> _loadJsonData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJsonString = prefs.getString('glucoseEntries');

      setState(() {
        if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
          // Pretty print the JSON for better readability
          final dynamic decodedJson = jsonDecode(entriesJsonString);
          _jsonData = JsonEncoder.withIndent('  ').convert(decodedJson);
        } else {
          _jsonData = 'No glucose data found in local storage.';
        }
      });
    } catch (e) {
      setState(() {
        _jsonData = 'Error loading data: $e';
      });
      _showMessage('Error loading data: $e');
    }
  }

  // Clears the 'glucoseEntries' key from shared_preferences
  Future<void> _clearJsonData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('glucoseEntries');
      setState(() {
        _jsonData = 'All glucose data cleared from local storage.';
      });
      _showMessage('Data cleared successfully!');
    } catch (e) {
      setState(() {
        _jsonData = 'Error clearing data: $e';
      });
      _showMessage('Error clearing data: $e');
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
        title: const Text('Glucose Data JSON Viewer'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Buttons for actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadJsonData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Show a confirmation dialog before clearing data
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: const Text('Confirm Clear Data'),
                            content: const Text(
                                'Are you sure you want to clear ALL glucose data? This action cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Dismiss dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _clearJsonData();
                                  Navigator.of(context).pop(); // Dismiss dialog
                                },
                                child: const Text('Clear Data'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display Area for JSON Data
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.green.shade50,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _jsonData,
                    style: const TextStyle(
                      fontFamily: 'monospace', // Use a monospace font for JSON
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
