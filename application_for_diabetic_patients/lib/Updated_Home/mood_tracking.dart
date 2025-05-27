
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class MoodEntry {
  final String id;
  final String username;
  final String mood;
  final DateTime dateTime;

  MoodEntry({
    required this.id,
    required this.username,
    required this.mood,
    required this.dateTime,
  });
}

class _MoodTrackerHomePageState extends State<MoodTrackerHomePage> {
  final String _username = "FlutterUser"; // Hardcoded username
  String? _selectedMood;
  final List<MoodEntry> _moodEntries = []; // List to store mood entries

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

  void _addMoodEntry() {
    if (_selectedMood == null || _selectedMood!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood.')),
      );
      return;
    }

    setState(() {
      final newEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        username: _username,
        mood: _selectedMood!,
        dateTime: DateTime.now(), // Automatic date and time
      );
      _moodEntries.insert(0, newEntry); // Add to the beginning
      _selectedMood = null; // Reset selected mood
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood entry added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
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
                                  'Recorded: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.dateTime)}',
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