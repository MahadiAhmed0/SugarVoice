// lib/utils/shared_prefs_utils.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SharedPrefsUtils {
  static const String _thoughtsKey = 'dailyThoughts';

  // Save a new thought with the current date
  static Future<void> saveThought(String thought) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final existingThoughts = prefs.getStringList(_thoughtsKey) ?? [];

    // Format: "YYYY-MM-DD: Your thought here"
    final newEntry = '$formattedDate: $thought';
    existingThoughts.add(newEntry);
    await prefs.setStringList(_thoughtsKey, existingThoughts);
  }

  // Retrieve all saved thoughts
  static Future<List<String>> getThoughts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_thoughtsKey) ?? [];
  }

  // Clear all thoughts (optional, for testing/reset)
  static Future<void> clearThoughts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_thoughtsKey);
  }
}