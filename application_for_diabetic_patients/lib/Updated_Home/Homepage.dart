import 'dart:async';
import 'package:application_for_diabetic_patients/Constansts.dart';
import 'package:application_for_diabetic_patients/Updated_Home/EmergencyPage.dart';
import 'package:application_for_diabetic_patients/Utils/gemini_service.dart';
import 'package:application_for_diabetic_patients/Utils/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'package:intl/intl.dart'; // Required for date formatting
import 'package:speech_to_text/speech_recognition_result.dart'; // Required for speech recognition
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts

// Import the other tracking pages and their models
import 'package:application_for_diabetic_patients/Updated_Home/glucose_input.dart';
import 'package:application_for_diabetic_patients/Updated_Home/journal_entry.dart';
import 'package:application_for_diabetic_patients/Updated_Home/meal_tracking.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mood_tracking.dart';
import 'package:application_for_diabetic_patients/Updated_Home/medicine_tracker.dart';

// Import gamification managers
import 'package:application_for_diabetic_patients/Updated_Home/achievement_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mission_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/streak_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/xp_tracker.dart';

// Re-defining models here for clarity and to ensure consistency with homepage parsing.
// Ideally, these would be in a separate `models.dart` file for reusability.

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

// --- JournalEntry Model (from journal_entry.dart, adapted for common structure) ---
class JournalEntry {
  final String id;
  final String username;
  final String title;
  final String content;
  final String timestamp; // Stored as ISO 8601 string for easy parsing

  JournalEntry({
    required this.id,
    required this.username,
    required this.title,
    required this.content,
    required this.timestamp,
  });
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      username: json['username'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}

// --- MealEntry Model (from meal_tracking.dart) ---
class MealEntry {
  final String id;
  final String mealDescription;
  final String timestamp;
  final String username;

  MealEntry({
    required this.id,
    required this.mealDescription,
    required this.timestamp,
    required this.username,
  });
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
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

// --- MoodEntry Model (from mood_tracking.dart) ---
class MoodEntry {
  final String id;
  final String username;
  final String mood;
  final String timestamp;

  MoodEntry({
    required this.id,
    required this.username,
    required this.mood,
    required this.timestamp,
  });
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
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
}

// --- MedicineLog Model (assuming it's defined in medicine_tracker.dart or a common models file) ---
class MedicineLog {
  final String id;
  final String username;
  final String medicineName;
  final String dosage;
  final String notes;
  final String timestamp; // When the medicine was actually taken/logged

  MedicineLog({
    required this.id,
    required this.username,
    required this.medicineName,
    required this.dosage,
    this.notes = '',
    required this.timestamp,
  });
  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: json['id'] as String,
      username: json['username'] as String,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String,
      notes: json['notes'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'medicineName': medicineName,
      'dosage': dosage,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }
}

// --- MedicineSchedule Model (assuming it's defined in medicine_tracker.dart or a common models file) ---
class MedicineSchedule {
  final String id;
  final String username;
  final String medicineName;
  final String dosage;
  final String frequency; // e.g., "Daily", "Weekly", "Specific Days"
  final List<String> reminderTimes; // List of times in "HH:mm" format
  final String startDate; // ISO 8601 date string
  final String? endDate; // ISO 8601 date string, nullable for ongoing
  final List<String> daysOfWeek; // e.g., ["Monday", "Wednesday"] for specific days
  final bool isActive;
  MedicineSchedule({
    required this.id,
    required this.username,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.daysOfWeek = const [],
    this.isActive = true,
  });
  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String,
      username: json['username'] as String,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      reminderTimes: List<String>.from(json['reminderTimes'] as List),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      daysOfWeek: List<String>.from(json['daysOfWeek'] as List? ?? []),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
    };
  }

  String get formattedSchedule {
    String times = reminderTimes.join(', ');
    if (frequency == 'Daily') {
      return '$frequency at $times';
    } else if (frequency == 'Weekly' && daysOfWeek.isNotEmpty) {
      return '$frequency on ${daysOfWeek.join(', ')} at $times';
    }
    return 'Schedule: $frequency at $times';
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
        cardTheme: CardThemeData(
          // Using CardThemeData for theme definition
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
  GeminiService _geminiService = GeminiService(apiKey: Gemini_API_KEY);
  String _geminiResponse = "";
  Timer? _speechClearTimer;
  // Hardcoded username as requested
  final String _username = "HealthUser";
  final SpeechService _speechService = SpeechService();
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  bool _isListeningForMedico = false;

  final FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts

  // Lists to store recent entries for each category
  List<MoodEntry> _recentMoodEntries = [];
  List<MealEntry> _recentMealEntries = [];
  List<GlucoseEntry> _recentGlucoseEntries = [];
  List<MedicineLog> _recentMedicineLogs = [];
  List<MedicineSchedule> _upcomingMedicineSchedules = [];

  // Gamification states
  int _currentXP = 0;
  int _currentLevel = 1;
  List<String> _unlockedAchievements = [];
  List<String> _weeklyMissions = [];
  List<String> _missionStatus = [];
  int _glucoseStreak = 0;
  int _moodStreak = 0;
  int _mealStreak = 0;

  // Current selected index for BottomNavigationBar
  // No longer needed as we're using Navigator.push
  // late final List<Widget> _pages;
  int _selectedIndex = 0; // Keep for BottomNavigationBar visual state

  @override
  void initState() {
    super.initState();
    _initTts(); // Initialize TTS
    _initGamification();
    _loadRecentRecords();
    _initSpeech(); // Initialize speech service
    _speakDailyGreeting(); // Speak greeting on app start
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS if it's speaking
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _speakDailyGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastGreetingDate = prefs.getString('last_greeting_date');
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastGreetingDate != todayDate) {
      // If the last greeting was not today, speak it and update the date
      String greeting = "Hello morning, Did you take your medicine today?";
      await _speak(greeting);
      await prefs.setString('last_greeting_date', todayDate);
    }
  }

  Future<void> _initGamification() async {
    await _loadGamificationData();
    await MissionManager.resetWeeklyMissions(); // Ensure missions are reset weekly
    _weeklyMissions = await MissionManager.getMissions();
    _missionStatus = await MissionManager.getMissionStatus();
    setState(() {}); // Update UI after loading gamification data
  }

  Future<void> _loadGamificationData() async {
    _currentXP = await XPTracker.getXP();
    _currentLevel = await XPTracker.getLevel();
    _unlockedAchievements = await AchievementManager.getAchievements();
    _glucoseStreak = await StreakManager.getStreak('glucose');
    _moodStreak = await StreakManager.getStreak('mood');
    _mealStreak = await StreakManager.getStreak('meal');
  }

  Future<void> _updateGamificationData() async {
    await _loadGamificationData();
    _weeklyMissions = await MissionManager.getMissions();
    _missionStatus = await MissionManager.getMissionStatus();
    setState(() {});
  }

  Future<void> _initSpeech() async {
    await _speechService.initSpeech();
    setState(() {});
  }

  void _startListening() async {
    await _speechService.startListening(_onSpeechResult, lang: 'en'); // Change locale as needed
    setState(() {
      _confidenceLevel = 0;
      _geminiResponse = "";
    });
  }

  void _stopListening() async {
    await _speechService.stopListening();
    setState(() {});
    // Set a timer to clear the speech text after a delay
    _speechClearTimer?.cancel();
    _speechClearTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _wordsSpoken = "";
        _confidenceLevel = 0;
        if (!_isListeningForMedico) {
          _geminiResponse = "";
        }
      });
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.toLowerCase();
    setState(() {
      _wordsSpoken = recognizedWords;
      _confidenceLevel = _speechService.getConfidenceLevel(result);
    });

    // Check for wake word if we're not already in Medico mode
    if (!_isListeningForMedico &&
        (recognizedWords.contains('medico') ||
            recognizedWords.contains('medical') ||
            recognizedWords.contains('mediko'))) {
      setState(() {
        _isListeningForMedico = true;
        _geminiResponse = "I'm listening for your health question...";
      });
      return;
    }

    // If we're in Medico mode, process the query when speech stops
    if (_isListeningForMedico && !_speechService.speechToText.isListening) {
      _handleGeminiQuery(recognizedWords);
      setState(() {
        _isListeningForMedico = false;
      });
      return;
    }

    // Only process commands if the speech has sufficient confidence and we're not in Medico mode
    if (_confidenceLevel > 0.7 && !_isListeningForMedico) {
      if (recognizedWords.contains('glucose') || recognizedWords.contains('sugar')) {
        _handleGlucoseCommand(recognizedWords);
      } else if (recognizedWords.contains('mood') || recognizedWords.contains('feeling')) {
        _handleMoodCommand(recognizedWords);
      } else if (recognizedWords.contains('meal') || recognizedWords.contains('food') || recognizedWords.contains('ate')) {
        _handleMealCommand(recognizedWords);
      }
    }

    // Reset the clear timer
    _speechClearTimer?.cancel();
    _speechClearTimer = Timer(const Duration(seconds: 2), () {
      if (!_speechService.speechToText.isListening && !_isListeningForMedico) {
        setState(() {
          _wordsSpoken = "";
          _confidenceLevel = 0;
          _geminiResponse = ""; // Clear Gemini response if not in medico mode
        });
      }
    });
  }

  void _handleGeminiQuery(String recognizedWords) async {
    // Extract the query after the wake word
    String query = recognizedWords;
    if (recognizedWords.contains('medico')) {
      query = recognizedWords.split('medico').last.trim();
    } else if (recognizedWords.contains('medical')) {
      query = recognizedWords.split('medical').last.trim();
    } else if (recognizedWords.contains('mediko')) {
      query = recognizedWords.split('mediko').last.trim();
    }

    if (query.isEmpty) {
      setState(() {
        _geminiResponse = "I'm listening for your health question...";
      });
      return;
    }

    // Get response from Gemini
    final response = await _geminiService.getSingleHealthResponse(query);
    setState(() {
      _geminiResponse = response;
    });
  }

  void _handleGlucoseCommand(String recognizedWords) async {
    String glucoseValue = recognizedWords.replaceAll(RegExp(r'[^0-9]'), '');
    if (glucoseValue.isEmpty) {
      setState(() {
        _geminiResponse = "I didn't hear a valid glucose value. Please say something like 'glucose 120'";
      });
      return;
    }

    final newEntry = GlucoseEntry(
      username: _username,
      glucoseValue: glucoseValue,
      timestamp: DateTime.now().toIso8601String(),
    );
    await _saveGlucoseEntry(newEntry);
    await XPTracker.addXP(10); // Award XP for logging glucose
    await StreakManager.logActivity('glucose'); // Log glucose activity for streak

    // Check for mission completion
    final prefs = await SharedPreferences.getInstance();
    List<GlucoseEntry> allGlucoseEntries = [];
    final String? entriesJsonString = prefs.getString('glucoseEntries');
    if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(entriesJsonString);
      allGlucoseEntries = jsonList.map((json) => GlucoseEntry.fromJson(json)).toList();
    }
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
    final glucoseLogsToday = allGlucoseEntries.where((entry) => DateFormat('yyyy-MM-dd').format(DateTime.parse(entry.timestamp)) == todayFormatted).length;

    for (int i = 0; i < _weeklyMissions.length; i++) {
      if (_weeklyMissions[i].contains('Log glucose') && glucoseLogsToday >= int.parse(_weeklyMissions[i].replaceAll(RegExp(r'[^0-9]'), ''))) {
        await MissionManager.complete(i);
        await AchievementManager.unlock('Glucose Logger'); // Example achievement
      }
    }

    setState(() {
      _geminiResponse = "Recorded glucose: $glucoseValue mg/dL";
      _recentGlucoseEntries.insert(0, newEntry);
      if (_recentGlucoseEntries.length > 5) {
        _recentGlucoseEntries = _recentGlucoseEntries.sublist(0, 5);
      }
      _updateGamificationData(); // Refresh gamification data
    });
  }

  Future<void> _saveGlucoseEntry(GlucoseEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJsonString = prefs.getString('glucoseEntries');
    List<dynamic> jsonList = [];
    if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
      jsonList = jsonDecode(entriesJsonString);
    }
    jsonList.add(entry.toJson());
    await prefs.setString('glucoseEntries', jsonEncode(jsonList));
  }

  void _handleMoodCommand(String recognizedWords) async {
    final moodMap = {
      'happy': 'Happy',
      'sad': 'Sad',
      'neutral': 'Neutral',
      'excited': 'Excited',
      'anxious': 'Anxious',
      'stressed': 'Stressed',
      'calm': 'Calm',
      'angry': 'Angry',
      'tired': 'Tired',
      'energetic': 'Energetic'
    };
    String? detectedMood;
    for (final entry in moodMap.entries) {
      if (recognizedWords.contains(entry.key)) {
        detectedMood = entry.value;
        break;
      }
    }

    if (detectedMood != null) {
      final newEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _username,
        mood: detectedMood,
        timestamp: DateTime.now().toIso8601String(),
      );
      await _saveMoodEntry(newEntry);
      await XPTracker.addXP(5); // Award XP for logging mood
      await StreakManager.logActivity('mood'); // Log mood activity for streak

      // Check for mission completion
      final prefs = await SharedPreferences.getInstance();
      List<MoodEntry> allMoodEntries = [];
      final String? entriesJsonString = prefs.getString('moodEntries');
      if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        allMoodEntries = jsonList.map((json) => MoodEntry.fromJson(json)).toList();
      }
      final today = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      final moodLogsToday = allMoodEntries.where((entry) => DateFormat('yyyy-MM-dd').format(DateTime.parse(entry.timestamp)) == todayFormatted).length;

      for (int i = 0; i < _weeklyMissions.length; i++) {
        if (_weeklyMissions[i].contains('Track mood') && moodLogsToday >= int.parse(_weeklyMissions[i].replaceAll(RegExp(r'[^0-9]'), ''))) {
          await MissionManager.complete(i);
          await AchievementManager.unlock('Mood Tracker'); // Example achievement
        }
      }

      setState(() {
        _geminiResponse = "Recorded mood: $detectedMood";
        _recentMoodEntries.insert(0, newEntry);
        if (_recentMoodEntries.length > 5) {
          _recentMoodEntries = _recentMoodEntries.sublist(0, 5);
        }
        _updateGamificationData(); // Refresh gamification data
      });
    } else {
      setState(() {
        _geminiResponse = "I didn't recognize the mood. Please say something like 'I feel happy'";
      });
    }
  }

  Future<void> _saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJsonString = prefs.getString('moodEntries');
    List<dynamic> jsonList = [];
    if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
      jsonList = jsonDecode(entriesJsonString);
    }
    jsonList.add(entry.toJson());
    await prefs.setString('moodEntries', jsonEncode(jsonList));
  }

  void _handleMealCommand(String recognizedWords) async {
    String mealDescription = recognizedWords;
    if (recognizedWords.contains('meal')) {
      mealDescription = recognizedWords.split('meal').last.trim();
    } else if (recognizedWords.contains('food')) {
      mealDescription = recognizedWords.split('food').last.trim();
    } else if (recognizedWords.contains('ate')) {
      mealDescription = recognizedWords.split('ate').last.trim();
    }

    if (mealDescription.isNotEmpty) {
      final newEntry = MealEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _username,
        mealDescription: mealDescription,
        timestamp: DateTime.now().toIso8601String(),
      );
      await _saveMealEntry(newEntry);
      await XPTracker.addXP(10); // Award XP for logging meal
      await StreakManager.logActivity('meal'); // Log meal activity for streak

      // Check for mission completion
      final prefs = await SharedPreferences.getInstance();
      List<MealEntry> allMealEntries = [];
      final String? entriesJsonString = prefs.getString('mealEntries');
      if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        allMealEntries = jsonList.map((json) => MealEntry.fromJson(json)).toList();
      }
      final today = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      final mealLogsToday = allMealEntries.where((entry) => DateFormat('yyyy-MM-dd').format(DateTime.parse(entry.timestamp)) == todayFormatted).length;

      for (int i = 0; i < _weeklyMissions.length; i++) {
        if (_weeklyMissions[i].contains('Log meals') && mealLogsToday >= int.parse(_weeklyMissions[i].replaceAll(RegExp(r'[^0-9]'), ''))) {
          await MissionManager.complete(i);
          await AchievementManager.unlock('Food Journaler'); // Example achievement
        }
      }

      setState(() {
        _geminiResponse = "Recorded meal: $mealDescription";
        _recentMealEntries.insert(0, newEntry);
        if (_recentMealEntries.length > 5) {
          _recentMealEntries = _recentMealEntries.sublist(0, 5);
        }
        _updateGamificationData(); // Refresh gamification data
      });
    } else {
      setState(() {
        _geminiResponse = "I didn't hear what you ate. Please say something like 'I ate pasta'";
      });
    }
  }

  Future<void> _saveMealEntry(MealEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJsonString = prefs.getString('mealEntries');
    List<dynamic> jsonList = [];
    if (entriesJsonString != null && entriesJsonString.isNotEmpty) {
      jsonList = jsonDecode(entriesJsonString);
    }
    jsonList.add(entry.toJson());
    await prefs.setString('mealEntries', jsonEncode(jsonList));
  }

  /// Loads recent records from SharedPreferences for Mood, Meal, Glucose, and Medicine.
  /// Filters entries to only include those from the last 3 days for logs,
  /// and relevant upcoming schedules for medicine.
  Future<void> _loadRecentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    // --- Load Mood Entries ---
    final String? moodEntriesJsonString = prefs.getString('moodEntries');
    if (moodEntriesJsonString != null && moodEntriesJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(moodEntriesJsonString);
        List<MoodEntry> allMoodEntries =
            jsonList.map((json) => MoodEntry.fromJson(json)).toList();
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
    if (mealEntriesJsonString != null && mealEntriesJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(mealEntriesJsonString);
        List<MealEntry> allMealEntries =
            jsonList.map((json) => MealEntry.fromJson(json)).toList();
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
    if (glucoseEntriesJsonString != null && glucoseEntriesJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(glucoseEntriesJsonString);
        List<GlucoseEntry> allGlucoseEntries =
            jsonList.map((json) => GlucoseEntry.fromJson(json)).toList();
        _recentGlucoseEntries = allGlucoseEntries
            .where((entry) => DateTime.parse(entry.timestamp).isAfter(threeDaysAgo))
            .toList();
        _recentGlucoseEntries.sort(
            (a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest
      } catch (e) {
        print('Error decoding glucose entries: $e');
      }
    }

    // --- Load Recent Medicine Logs ---
    final String? medicineLogsJsonString = prefs.getString('medicineLogs');
    if (medicineLogsJsonString != null && medicineLogsJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(medicineLogsJsonString);
        List<MedicineLog> allMedicineLogs =
            jsonList.map((json) => MedicineLog.fromJson(json)).toList();
        _recentMedicineLogs = allMedicineLogs
            .where((log) => DateTime.parse(log.timestamp).isAfter(threeDaysAgo))
            .toList();
        _recentMedicineLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        print('Error decoding medicine logs: $e');
      }
    }

    // --- Load Upcoming Medicine Schedules ---
    final String? medicineSchedulesJsonString = prefs.getString('medicineSchedules');
    if (medicineSchedulesJsonString != null && medicineSchedulesJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(medicineSchedulesJsonString);
        List<MedicineSchedule> allSchedules =
            jsonList.map((json) => MedicineSchedule.fromJson(json)).toList();
        // Filter for active and upcoming schedules
        List<MedicineSchedule> relevantSchedules = [];
        final now = DateTime.now();
        for (var schedule in allSchedules) {
          if (!schedule.isActive) continue;
          final startDate = DateTime.parse(schedule.startDate);
          if (schedule.endDate != null) {
            final endDate = DateTime.parse(schedule.endDate!);
            if (now.isAfter(endDate)) continue; // Schedule has ended
          }
          if (now.isBefore(startDate.subtract(const Duration(days: 1)))) continue; // Schedule hasn't started yet (give some buffer)

          // Check if today is one of the scheduled days for weekly frequency
          if (schedule.frequency == 'Weekly' && schedule.daysOfWeek.isNotEmpty) {
            final String todayDay = DateFormat('EEEE').format(now); // e.g., "Wednesday"
            if (!schedule.daysOfWeek.contains(todayDay)) {
              continue; // Not scheduled for today
            }
          }

          // Check if there's an upcoming reminder time today or very soon (e.g., within next 24 hours)
          bool hasUpcomingReminder = false;
          for (String timeStr in schedule.reminderTimes) {
            final parts = timeStr.split(':');
            if (parts.length != 2) continue; // Invalid time format
            final int hour = int.parse(parts[0]);
            final int minute = int.parse(parts[1]);

            final DateTime reminderDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );
            // Consider reminders in the future or very recently passed (e.g., within last 15 mins)
            if (reminderDateTime.isAfter(now.subtract(const Duration(minutes: 15))) &&
                reminderDateTime.isBefore(now.add(const Duration(days: 1)))) {
              hasUpcomingReminder = true;
              break;
            }
          }
          if (hasUpcomingReminder) {
            relevantSchedules.add(schedule);
          }
        }
        _upcomingMedicineSchedules = relevantSchedules;
        // Sort upcoming schedules (e.g., by medicine name or first reminder time)
        _upcomingMedicineSchedules.sort((a, b) => a.medicineName.compareTo(b.medicineName));
      } catch (e) {
        print('Error decoding medicine schedules: $e');
      }
    }

    // Update the UI once all data is loaded and filtered
    setState(() {});
  }

  // Modified _onItemTapped to use Navigator.push and reload data on pop
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index; // Update selected index immediately for visual feedback
    });

    Widget pageToPush;
    switch (index) {
      case 0: // Home - no push needed, already there or navigated back to
        return;
      case 1:
        pageToPush = const GlucoseEntryScreen();
        break;
      case 2:
        pageToPush = const JournalEntryScreen();
        break;
      case 3:
        pageToPush = const MealTrackerHomePage();
        break;
      case 4:
        pageToPush = const MoodTrackerHomePage();
        break;
      case 5:
        pageToPush = const MedicineTrackerApp();
        break;
      case 6:
        pageToPush = const EmergencyPage();
        break;
      default:
        pageToPush = _buildDashboardView(); // Fallback to home
    }

    // Push the new page and wait for it to be popped
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pageToPush),
    );

    // When the pushed page is popped, reload all recent records and gamification data
    _loadRecentRecords();
    _updateGamificationData();
  }

  // This method builds the main dashboard view, which will be the first page.
  Widget _buildDashboardView() {
    return SingleChildScrollView(
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

          // Gamification Summary
          _buildGamificationSummary(),
          const SizedBox(height: 20),

          // Weekly Missions
          _buildWeeklyMissions(),
          const SizedBox(height: 20),

          // Streaks
          _buildStreaks(),
          const SizedBox(height: 20),

          // Achievements
          _buildAchievements(),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Recorded: ${entry.formattedTimestamp}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20),

          // --- Medicine Reminder Section ---
          _buildSectionTitle('Upcoming Medicine Reminders'),
          _upcomingMedicineSchedules.isEmpty
              ? _buildNoRecordsMessage('No upcoming medicine reminders.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _upcomingMedicineSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _upcomingMedicineSchedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      color: Colors.purple.shade50, // Light purple for medicine cards
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${schedule.medicineName} - ${schedule.dosage}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schedule: ${schedule.formattedSchedule}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            Text(
                              'Times: ${schedule.reminderTimes.join(', ')}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20),

          // --- Recent Medicine Logs Section ---
          _buildSectionTitle('Recent Medicine Logs'),
          _recentMedicineLogs.isEmpty
              ? _buildNoRecordsMessage('No recent medicine logs.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentMedicineLogs.length,
                  itemBuilder: (context, index) {
                    final log = _recentMedicineLogs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      color: Colors.purple.shade50, // Light purple for medicine cards
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log.medicineName} - ${log.dosage}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Taken: ${log.formattedTimestamp}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            if (log.notes.isNotEmpty)
                              Text(
                                'Notes: ${log.notes}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // New Widget: Gamification Summary
  Widget _buildGamificationSummary() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.lightGreen.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.lightGreenAccent),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(
                  'XP',
                  _currentXP.toString(),
                  Icons.star,
                  Colors.amber,
                ),
                _buildProgressItem(
                  'Level',
                  _currentLevel.toString(),
                  Icons.military_tech,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for progress items
  Widget _buildProgressItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // New Widget: Weekly Missions
  Widget _buildWeeklyMissions() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Missions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.orangeAccent),
            const SizedBox(height: 10),
            if (_weeklyMissions.isEmpty)
              _buildNoRecordsMessage('No weekly missions available.'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weeklyMissions.length,
              itemBuilder: (context, index) {
                final mission = _weeklyMissions[index];
                final isCompleted = _missionStatus[index] == '1';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        mission,
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted ? Colors.green : Colors.black87,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // New Widget: Streaks
  Widget _buildStreaks() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streaks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.redAccent),
            const SizedBox(height: 10),
            _buildStreakItem('Glucose Log Streak', _glucoseStreak),
            _buildStreakItem('Mood Track Streak', _moodStreak),
            _buildStreakItem('Meal Log Streak', _mealStreak),
          ],
        ),
      ),
    );
  }

  // Helper for streak items
  Widget _buildStreakItem(String label, int streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Text(
            '$label: $streak days',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // New Widget: Achievements
  Widget _buildAchievements() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.cyan.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.cyanAccent),
            const SizedBox(height: 10),
            if (_unlockedAchievements.isEmpty)
              _buildNoRecordsMessage('No achievements unlocked yet.'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unlockedAchievements.length,
              itemBuilder: (context, index) {
                final achievement = _unlockedAchievements[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(
                        achievement,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildDashboardView(), // The main content of the homepage
          if (_wordsSpoken.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  children: [
                    Text(
                      _wordsSpoken,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_confidenceLevel > 0)
                      Text(
                        "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_geminiResponse.isNotEmpty)
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.withOpacity(0.7),
                child: Column(
                  children: [
                    const Text(
                      "Medico Response:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _geminiResponse,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          if (_isListeningForMedico)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Listening for health query...",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Glucose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied_alt),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            // Added Medicine Tracker icon
            icon: Icon(Icons.medical_services),
            label: 'Meds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Emerg',
          )
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechService.speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechService.speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: _isListeningForMedico
            ? Colors.green
            : (_speechService.speechToText.isListening
                ? Colors.deepPurple
                : Colors.deepPurple),
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