import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models_bangla.dart'; // Import your models

class MedicineLogPage extends StatefulWidget {
  final String username;
  const MedicineLogPage({super.key, required this.username});

  @override
  State<MedicineLogPage> createState() => _MedicineLogPageState();
}

class _MedicineLogPageState extends State<MedicineLogPage> {
  final TextEditingController _medicineNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<MedicineLog> _medicineLogs = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMedicineLogs();
  }

  Future<void> _loadMedicineLogs() async {
    try {
      final String? logsJsonString = _prefs.getString('medicineLogs');
      if (logsJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(logsJsonString);
        setState(() {
          _medicineLogs = jsonList.map((json) => MedicineLog.fromJson(json)).toList();
          // Sort by latest timestamp first
          _medicineLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      _showMessage('ঔষধ লগ লোড করতে ত্রুটি: $e');
      print('Error loading medicine logs: $e');
    }
  }

  void _logMedicineTaken() {
    if (_formKey.currentState!.validate()) {
      final newLog = MedicineLog(
        medicineName: _medicineNameController.text,
        timestamp: DateTime.now().toIso8601String(), // Automatic timestamp
      );

      setState(() {
        _medicineLogs.add(newLog);
        _medicineLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by latest first
      });

      _persistMedicineLogs();
      _medicineNameController.clear();
      _showMessage('ঔষধ সফলভাবে লগ হয়েছে!');
    }
  }

  void _deleteMedicineLog(String id) {
    setState(() {
      _medicineLogs.removeWhere((log) => log.id == id);
    });
    _persistMedicineLogs();
    _showMessage('ঔষধ লগ মুছে ফেলা হয়েছে।');
  }

  Future<void> _persistMedicineLogs() async {
    try {
      final List<Map<String, dynamic>> jsonList = _medicineLogs.map((log) => log.toJson()).toList();
      await _prefs.setString('medicineLogs', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('ঔষধ লগ সংরক্ষণ করতে ত্রুটি: $e');
      print('Error saving medicine logs: $e');
    }
  }

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
         
          const SizedBox(height: 20),
          Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _medicineNameController,
                      decoration: const InputDecoration(
                        labelText: 'ঔষধ নেওয়া',
                        hintText: 'যেমন: মেটফর্মিন',
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'দয়া করে নেওয়া ঔষধের নাম লিখুন।';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logMedicineTaken,
                      child: const Text('ঔষধ লগ করুন'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'আপনার ঔষধ লগ ইতিহাস:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30, thickness: 1, color: Colors.lightBlue),
          Expanded(
            child: _medicineLogs.isEmpty
                ? Center(
                    child: Text(
                      'এখনো কোন ঔষধ লগ হয়নি।\nএকটি লগ করুন!',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _medicineLogs.length,
                    itemBuilder: (context, index) {
                      final log = _medicineLogs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        elevation: 3,
                        color: Colors.deepPurple.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.medicineName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMedicineLog(log.id),
                                    tooltip: 'লগ মুছুন',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'লগ করা হয়েছে: ${log.formattedTimestamp}',
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
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
    );
  }
}
