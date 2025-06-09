import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart'; // Import your models

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
      _showMessage('Error loading medicine logs: $e');
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
      _showMessage('Medicine logged successfully!');
    }
  }

  void _deleteMedicineLog(String id) {
    setState(() {
      _medicineLogs.removeWhere((log) => log.id == id);
    });
    _persistMedicineLogs();
    _showMessage('Medicine log deleted.');
  }

  Future<void> _persistMedicineLogs() async {
    try {
      final List<Map<String, dynamic>> jsonList = _medicineLogs.map((log) => log.toJson()).toList();
      await _prefs.setString('medicineLogs', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving medicine logs: $e');
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
                        labelText: 'Medicine Taken',
                        hintText: 'e.g., Metformin',
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the medicine taken.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logMedicineTaken,
                      child: const Text('Log Medicine Taken'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Medicine Log History:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30, thickness: 1, color: Colors.deepPurpleAccent),
          Expanded(
            child: _medicineLogs.isEmpty
                ? Center(
                    child: Text(
                      'No medicines logged yet. Log one!',
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
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMedicineLog(log.id),
                                    tooltip: 'Delete Log',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Logged at: ${log.formattedTimestamp}',
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