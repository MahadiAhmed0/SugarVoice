// journal_entry_bangla.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'updated_achievement_manager_bangla.dart';
import 'updated_mission_manager_bangla.dart';
import 'updated_streak_manager_bangla.dart';
import 'xp_tracker_bangla.dart';

class JournalEntryBangla {
  final String id;
  final String username;
  final String title;
  final String content;
  final String timestamp;

  JournalEntryBangla({
    required this.id,
    required this.username,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory JournalEntryBangla.fromJson(Map<String, dynamic> json) {
    return JournalEntryBangla(
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

class JournalBangla extends StatelessWidget {
  const JournalBangla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ডায়েরি',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kalpurush',
      ),
      home: const JournalBanglaScreen(),
    );
  }
}

class JournalBanglaScreen extends StatefulWidget {
  const JournalBanglaScreen({super.key});

  @override
  State<JournalBanglaScreen> createState() => _JournalBanglaScreenState();
}

class _JournalBanglaScreenState extends State<JournalBanglaScreen> {
  final TextEditingController _contentController = TextEditingController();
  final String _username = "ব্যবহারকারী";
  List<JournalEntryBangla> _journalEntries = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final String? entriesJsonString = _prefs.getString('journalEntriesBangla');
      if (entriesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(entriesJsonString);
        setState(() {
          _journalEntries = jsonList.map((json) => JournalEntryBangla.fromJson(json)).toList();
          _journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('ডায়েরি এন্ট্রি লোড করতে ত্রুটি: $e');
    }
  }

  void _saveJournalEntry() async {
    if (_contentController.text.isNotEmpty) {
      final newEntry = JournalEntryBangla(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _username,
        title: 'ডায়েরি এন্ট্রি',
        content: _contentController.text,
        timestamp: DateTime.now().toIso8601String(),
      );
      
      setState(() {
        _journalEntries.add(newEntry);
        _journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
      
      await _persistJournalEntries();
      _contentController.clear();
      _showMessage('ডায়েরি সংরক্ষণ করা হয়েছে');

      await XPTracker.addXP(15);
      await AchievementManager.unlock('ডায়েরি লেখক');
    } else {
      _showMessage('কিছু লিখুন');
    }
  }

  void _deleteJournalEntry(String id) {
    setState(() {
      _journalEntries.removeWhere((entry) => entry.id == id);
    });
    _persistJournalEntries();
    _showMessage('ডায়েরি এন্ট্রি মুছে ফেলা হয়েছে');
  }

  Future<void> _persistJournalEntries() async {
    try {
      final List<Map<String, dynamic>> jsonList = _journalEntries.map((entry) => entry.toJson()).toList();
      await _prefs.setString('journalEntriesBangla', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('ডায়েরি সংরক্ষণ করতে ত্রুটি: $e');
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
        title: const Text('ডায়েরি'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'ব্যবহারকারী: $_username',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'আপনার আজকের দিনটি কেমন গেল?',
                hintText: 'আপনার অনুভূতি লিখুন...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveJournalEntry,
              child: const Text('সংরক্ষণ করুন'),
            ),
            const SizedBox(height: 30),
            const Text(
              'আপনার ডায়েরি এন্ট্রি',
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _journalEntries.isEmpty
                  ? const Center(
                      child: Text('কোনো ডায়েরি এন্ট্রি নেই'),
                    )
                  : ListView.builder(
                      itemCount: _journalEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _journalEntries[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.formattedTimestamp),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteJournalEntry(entry.id),
                                    ),
                                  ],
                                ),
                                Text(entry.content),
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