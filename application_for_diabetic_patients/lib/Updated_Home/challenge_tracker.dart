import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChallengeTracker {
  static const _activeChallengesKey = 'active_challenges';
  static const _completedChallengesKey = 'completed_challenges';

  // Example challenges (can be loaded dynamically or defined here)
  static const List<String> _predefinedChallenges = [
    'Log glucose 7 days in a row',
    'Track mood 5 different times in a week',
    'Log 10 meals in a week',
    'Take all scheduled medicines for 3 days',
  ];

  /// Activates a set of challenges.
  /// In a real app, this might involve more complex logic, e.g., daily/weekly challenges.
  static Future<void> activateChallenges(List<String> challengesToActivate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_activeChallengesKey, challengesToActivate);
    // Reset progress for new challenges
    for (var challenge in challengesToActivate) {
      await prefs.setInt('challenge_progress_$challenge', 0);
    }
  }

  /// Logs progress for a specific challenge.
  /// Returns true if the challenge is completed.
  static Future<bool> logProgress(String challengeName, int progressAmount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentProgress = prefs.getInt('challenge_progress_$challengeName') ?? 0;
    currentProgress += progressAmount;
    await prefs.setInt('challenge_progress_$challengeName', currentProgress);

    // Logic to check for completion
    // This is a simplified example; actual completion criteria would vary
    bool completed = false;
    if (challengeName.contains('glucose 7 days') && currentProgress >= 7) {
      completed = true;
    } else if (challengeName.contains('mood 5 different times') && currentProgress >= 5) {
      completed = true;
    } else if (challengeName.contains('10 meals') && currentProgress >= 10) {
      completed = true;
    } else if (challengeName.contains('scheduled medicines for 3 days') && currentProgress >= 3) {
      completed = true;
    }

    if (completed) {
      await completeChallenge(challengeName);
    }
    return completed;
  }

  /// Marks a challenge as completed and moves it to completed list.
  static Future<void> completeChallenge(String challengeName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeChallenges = prefs.getStringList(_activeChallengesKey) ?? [];
    List<String> completedChallenges = prefs.getStringList(_completedChallengesKey) ?? [];

    if (activeChallenges.contains(challengeName) && !completedChallenges.contains(challengeName)) {
      activeChallenges.remove(challengeName);
      completedChallenges.add(challengeName);
      await prefs.setStringList(_activeChallengesKey, activeChallenges);
      await prefs.setStringList(_completedChallengesKey, completedChallenges);
      await prefs.remove('challenge_progress_$challengeName'); // Clear progress

      _speak("Challenge completed: $challengeName! Great job!");
    }
  }

  /// Gets currently active challenges.
  static Future<List<String>> getActiveChallenges() async =>
      (await SharedPreferences.getInstance()).getStringList(_activeChallengesKey) ?? [];

  /// Gets a list of all completed challenges.
  static Future<List<String>> getCompletedChallenges() async =>
      (await SharedPreferences.getInstance()).getStringList(_completedChallengesKey) ?? [];

  /// Gets the progress for a specific active challenge.
  static Future<int> getProgress(String challengeName) async =>
      (await SharedPreferences.getInstance()).getInt('challenge_progress_$challengeName') ?? 0;

  static void _speak(String text) async {
    final tts = FlutterTts();
    await tts.speak(text);
  }
}