import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

// --- MealEntry Model ---
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
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
}
// --- End MealEntry Model ---

class MealTrackerApp extends StatelessWidget {
  const MealTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as per instructions
      ),
      home: const MealTrackerHomePage(),
    );
  }
}

class MealTrackerHomePage extends StatefulWidget {
  const MealTrackerHomePage({super.key});

  @override
  State<MealTrackerHomePage> createState() => _MealTrackerHomePageState();
}

class _MealTrackerHomePageState extends State<MealTrackerHomePage> {
  // Hardcoded username as requested
  final String _username = "JohnDoe";
  // List of meal types
  final List<String> _mealTypes = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snacks",
    "Other"
  ];
  // Currently selected meal type
  String? _selectedMealType;

  // Controller for the meal input field
  final TextEditingController _mealController = TextEditingController();
  // Variable to store the current date and time for display, automatically updated
  DateTime _currentDateTime = DateTime.now();
  // List to store tracked meals
  List<MealEntry> _trackedMeals = []; // Changed to store MealEntry objects
  // Timer for updating the current date and time display
  late final Ticker _ticker; // Using Ticker for more efficient time updates
  late SharedPreferences _prefs; // SharedPreferences instance

  @override
  void initState() {
    super.initState();
    // Set initial selected meal type to the first one
    _selectedMealType = _mealTypes[0];
    // Initialize a Ticker to update the current time display every second
    _ticker = Ticker((Duration elapsed) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    })..start();
    _initSharedPreferences(); // Initialize SharedPreferences and load data
  }

  @override
  void dispose() {
    _mealController.dispose();
    _ticker.dispose(); // Dispose the ticker when the widget is removed
    super.dispose();
  }

  // --- SharedPreferences Initialization & CRUD Operations ---

  /// Initializes SharedPreferences and then loads existing meal entries.
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMealEntries();
  }

  /// Read: Loads meal entries from local storage (SharedPreferences).
  Future<void> _loadMealEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('mealEntries');
      if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _trackedMeals = jsonList.map((json) => MealEntry.fromJson(json)).toList();
          // Sort by latest timestamp first upon loading
          _trackedMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('Error loading meal entries: $e');
      print('Error loading meal entries: $e'); // For debugging
    }
  }

  /// Create: Saves a new meal entry to local storage.
  void _saveMealEntry() {
    if (_mealController.text.isNotEmpty && _selectedMealType != null) {
      final newEntry = MealEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        username: _username,
        mealDescription: _mealController.text,
        timestamp: DateTime.now().toIso8601String(), // Automatic timestamp
      );
      setState(() {
        _trackedMeals.add(newEntry); // Add new entry to the list
        _trackedMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest first
      });
      _persistMealEntries(); // Persist the updated list to SharedPreferences
      _mealController.clear(); // Clear the input field after saving
      _showMessage('Meal added: ${_selectedMealType!} - ${newEntry.mealDescription}');
    } else {
      _showMessage('Please enter a meal and select a meal type.');
    }
  }

  /// Delete: Removes a meal entry from local storage based on its ID.
  void _deleteMealEntry(String id) {
    setState(() {
      _trackedMeals.removeWhere((entry) => entry.id == id);
    });
    _persistMealEntries(); // Persist the updated list
    _showMessage('Meal entry deleted.');
  }

  /// Helper to persist the current list of entries to local storage.
  Future<void> _persistMealEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _trackedMeals.map((entry) => entry.toJson()).toList();
      await _prefs.setString('mealEntries', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving meal entries: $e');
      print('Error saving meal entries: $e'); // For debugging
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

  // Helper function to get icon based on meal type
  IconData _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case "Breakfast":
        return Icons.free_breakfast;
      case "Lunch":
        return Icons.lunch_dining;
      case "Dinner":
        return Icons.dinner_dining;
      case "Snacks":
        return Icons.cookie;
      case "Other":
        return Icons.more_horiz;
      default:
        return Icons.fastfood;
    }
  }

  // Function to show a confirmation dialog before deleting a meal
  void _showDeleteConfirmationDialog(String entryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Delete Meal'),
          content: const Text('Are you sure you want to delete this meal entry?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteMealEntry(entryId);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Tracker'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display username
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome, $_username!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Meal Type Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.5).round()),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMealType,
                  hint: const Text('Select Meal Type'),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  iconSize: 28,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMealType = newValue;
                    });
                  },
                  items: _mealTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display current Date and Time (automatically set)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.5).round()),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.access_time, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Current Date & Time: ${DateFormat('MMM dd, yyyy - hh:mm:ss a').format(_currentDateTime)}',
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal Input Field
            TextField(
              controller: _mealController,
              decoration: InputDecoration(
                labelText: 'Enter your meal',
                hintText: 'e.g., Chicken salad with quinoa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
                prefixIcon: const Icon(Icons.fastfood, color: Colors.blueGrey),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Add Meal Button
            ElevatedButton(
              onPressed: _saveMealEntry, // Changed to _saveMealEntry
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button background color
                foregroundColor: Colors.white, // Button text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.blueAccent.withAlpha((255 * 0.5).round()),
              ),
              child: const Text(
                'Add Meal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // Tracked Meals List Header
            const Text(
              'Tracked Meals:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.blueGrey),

            // List of Tracked Meals
            Expanded(
              child: _trackedMeals.isEmpty
                  ? Center(
                      child: Text(
                        'No meals tracked yet. Add your first meal!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _trackedMeals.length,
                      itemBuilder: (context, index) {
                        final mealEntry = _trackedMeals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.withAlpha((255 * 0.5).round()),
                              child: Icon(
                                _getMealTypeIcon(_selectedMealType ?? 'Other'), // Use _selectedMealType or a default
                                color: Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              mealEntry.mealDescription, // Access mealDescription from object
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${_selectedMealType} - ${mealEntry.formattedTimestamp}', // Use formattedTimestamp
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _showDeleteConfirmationDialog(mealEntry.id); // Pass the entry's ID
                              },
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