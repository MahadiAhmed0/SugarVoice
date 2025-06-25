// glucose_input_bangla.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'updated_achievement_manager_bangla.dart';
import 'updated_mission_manager_bangla.dart';
import 'updated_streak_manager_bangla.dart';
import 'xp_tracker_bangla.dart';

class GlucoseEntryBangla {
  final String username;
  final String glucoseValue;
  final String timestamp;
  final String id;

  GlucoseEntryBangla({
    required this.username,
    required this.glucoseValue,
    required this.timestamp,
    String? id,
  }) : id = id ?? DateTime.now().toIso8601String();

  factory GlucoseEntryBangla.fromJson(Map<String, dynamic> json) {
    return GlucoseEntryBangla(
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

  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}

class GlucoseTrackerBangla extends StatelessWidget {
  const GlucoseTrackerBangla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'গ্লুকোজ ট্র্যাকার',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Kalpurush', // Use a Bangla font
      ),
      home: const GlucoseEntryBanglaScreen(),
    );
  }
}

class GlucoseEntryBanglaScreen extends StatefulWidget {
  const GlucoseEntryBanglaScreen({super.key});

  @override
  State<GlucoseEntryBanglaScreen> createState() => _GlucoseEntryBanglaScreenState();
}

class _GlucoseEntryBanglaScreenState extends State<GlucoseEntryBanglaScreen> {
  final TextEditingController _glucoseController = TextEditingController();
  final String _savedUsername = 'ব্যবহারকারী';
  final _formKey = GlobalKey<FormState>();
  List<GlucoseEntryBangla> _glucoseEntries = [];

  @override
  void initState() {
    super.initState();
    _loadGlucoseEntries();
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _loadGlucoseEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJsonString = prefs.getString('glucoseEntriesBangla');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _glucoseEntries = jsonList.map((json) => GlucoseEntryBangla.fromJson(json)).toList();
        });
      }
    } catch (e) {
      _showMessage('এন্ট্রি লোড করতে ত্রুটি: $e');
    }
  }

  void _saveGlucoseEntry() async {
    if (_formKey.currentState!.validate()) {
      final newEntry = GlucoseEntryBangla(
        username: _savedUsername,
        glucoseValue: _glucoseController.text,
        timestamp: DateTime.now().toIso8601String(),
      );
      setState(() {
        _glucoseEntries.add(newEntry);
        _glucoseEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
      await _persistGlucoseEntries();
      _glucoseController.clear();
      _showMessage('গ্লুকোজের তথ্য সফলভাবে সংরক্ষণ করা হয়েছে!');

      await XPTracker.addXP(10);
      await StreakManager.logActivity('glucose');
    }
  }

  void _deleteGlucoseEntry(String id) {
    setState(() {
      _glucoseEntries.removeWhere((entry) => entry.id == id);
    });
    _persistGlucoseEntries();
    _showMessage('এন্ট্রি মুছে ফেলা হয়েছে।');
  }

  Future<void> _persistGlucoseEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _glucoseEntries.map((entry) => entry.toJson()).toList();
      await prefs.setString('glucoseEntriesBangla', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('এন্ট্রি সংরক্ষণ করতে ত্রুটি: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('গ্লুকোজ ট্র্যাকার'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _glucoseController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      labelText: 'গ্লুকোজের মাত্রা (mg/dL)',
                      hintText: 'যেমন, ১২০',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'গ্লুকোজের মাত্রা লিখুন';
                      }
                      if (int.tryParse(value) == null) {
                        return 'সঠিক সংখ্যা লিখুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveGlucoseEntry,
                    child: const Text('সংরক্ষণ করুন'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _glucoseEntries.isEmpty
                  ? const Center(
                      child: Text(
                        'কোনো গ্লুকোজের তথ্য নেই। নতুন তথ্য যোগ করুন!',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _glucoseEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _glucoseEntries[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ব্যবহারকারী: ${entry.username}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'গ্লুকোজ: ${entry.glucoseValue} mg/dL',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        'সময়: ${entry.formattedTimestamp}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteGlucoseEntry(entry.id),
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