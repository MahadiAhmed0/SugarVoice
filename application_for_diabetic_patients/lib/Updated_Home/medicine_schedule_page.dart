import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart'; // Import your models

class MedicineSchedulePage extends StatefulWidget {
  final String username;
  const MedicineSchedulePage({super.key, required this.username});

  @override
  State<MedicineSchedulePage> createState() => _MedicineSchedulePageState();
}

class _MedicineSchedulePageState extends State<MedicineSchedulePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<MedicineSchedule> _scheduledMedicines = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadScheduledMedicines();
  }

  Future<void> _loadScheduledMedicines() async {
    try {
      final String? medicinesJsonString = _prefs.getString('scheduledMedicines');
      if (medicinesJsonString != null) {
        final List<dynamic> jsonList = jsonDecode(medicinesJsonString);
        setState(() {
          _scheduledMedicines = jsonList.map((json) => MedicineSchedule.fromJson(json)).toList();
        });
      }
    } catch (e) {
      _showMessage('Error loading scheduled medicines: $e');
      print('Error loading scheduled medicines: $e');
    }
  }

  void _saveMedicineSchedule() {
    if (_formKey.currentState!.validate()) {
      final newSchedule = MedicineSchedule(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
      );

      setState(() {
        _scheduledMedicines.add(newSchedule);
      });

      _persistScheduledMedicines();
      _nameController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _showMessage('Medicine schedule added!');
    }
  }

  void _deleteMedicineSchedule(String id) {
    setState(() {
      _scheduledMedicines.removeWhere((schedule) => schedule.id == id);
    });
    _persistScheduledMedicines();
    _showMessage('Medicine schedule deleted.');
  }

  Future<void> _persistScheduledMedicines() async {
    try {
      final List<Map<String, dynamic>> jsonList = _scheduledMedicines.map((schedule) => schedule.toJson()).toList();
      await _prefs.setString('scheduledMedicines', jsonEncode(jsonList));
    } catch (e) {
      _showMessage('Error saving scheduled medicines: $e');
      print('Error saving scheduled medicines: $e');
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
          Text(
            'Hello, ${widget.username}!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            textAlign: TextAlign.center,
          ),
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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter medicine name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 5mg, 1 tablet)',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter dosage.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _frequencyController,
                      decoration: const InputDecoration(
                        labelText: 'Frequency/Instructions (e.g., Once daily, Before meals)',
                        prefixIcon: Icon(Icons.alarm),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter frequency/instructions.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveMedicineSchedule,
                      child: const Text('Add Medicine to Schedule'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Scheduled Medicines:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30, thickness: 1, color: Colors.deepPurpleAccent),
          Expanded(
            child: _scheduledMedicines.isEmpty
                ? Center(
                    child: Text(
                      'No medicines scheduled yet. Add one!',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _scheduledMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = _scheduledMedicines[index];
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
                                  Expanded(
                                    child: Text(
                                      medicine.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMedicineSchedule(medicine.id),
                                    tooltip: 'Delete Schedule',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dosage: ${medicine.dosage}',
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Instructions: ${medicine.frequency}',
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
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