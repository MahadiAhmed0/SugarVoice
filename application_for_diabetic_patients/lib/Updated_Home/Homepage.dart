import 'package:flutter/material.dart';
import 'package:application_for_diabetic_patients/Updated_Home/xp_tracker.dart';
import 'package:application_for_diabetic_patients/Updated_Home/streak_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/achievement_manager.dart';
import 'package:application_for_diabetic_patients/Updated_Home/mission_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int xp = 0;
  int level = 1;
  int glucoseStreak = 0;
  int moodStreak = 0;
  List<String> achievements = [];
  List<String> missions = [];
  List<String> missionStatus = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final xp = await XPTracker.getXP();
    final level = await XPTracker.getLevel();
    final gStreak = await StreakManager.getStreak('glucose');
    final mStreak = await StreakManager.getStreak('mood');
    final achievements = await AchievementManager.getAchievements();
    final missions = await MissionManager.getMissions();
    final missionStatus = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getStringList('weekly_mission') ?? List.filled(missions.length, '0'));

    setState(() {
      xp = xp;
      level = level;
      glucoseStreak = gStreak;
      moodStreak = mStreak;
      achievements = achievements;
      missions = missions;
      missionStatus = missionStatus;
    });
  }

  Widget buildCard(String title, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: [
            buildCard('Level & XP', Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level: $level', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: xp / (level * 100),
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 4),
                Text('$xp / ${level * 100} XP'),
              ],
            )),
            buildCard('Streaks', Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  const Text('Glucose'),
                  Text('$glucoseStreak days')
                ]),
                Column(children: [
                  const Text('Mood'),
                  Text('$moodStreak days')
                ]),
              ],
            )),
            buildCard('Achievements', Wrap(
              spacing: 8,
              children: achievements.map((a) => Chip(label: Text(a))).toList(),
            )),
            buildCard('Weekly Missions', Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(missions.length, (i) => Row(
                children: [
                  Icon(
                    missionStatus[i] == '1' ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: missionStatus[i] == '1' ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(missions[i]),
                ],
              )),
            )),
          ],
        ),
      ),
    );
  }
}
