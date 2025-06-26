import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
class BanglaEmergencyPage extends StatefulWidget {
  const BanglaEmergencyPage({Key? key}) : super(key: key);

  @override
  State<BanglaEmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<BanglaEmergencyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Map<String, String>> _contacts = [];
@override
void initState() {
  super.initState();
  _loadContacts();
}
Future<void> _loadContacts() async {
  final prefs = await SharedPreferences.getInstance();
  final String? contactsJsonString = prefs.getString('emergencyContacts');
  
  if (contactsJsonString != null && contactsJsonString.isNotEmpty) {
    try {
      final List<dynamic> jsonList = jsonDecode(contactsJsonString);
      setState(() {
        _contacts = jsonList.map((json) => 
          Map<String, String>.from(json as Map)).toList();
      });
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }
}
 void _addContact() async {
  final name = _nameController.text;
  final phone = _phoneController.text;
  if (name.isNotEmpty && phone.isNotEmpty) {
    setState(() {
      _contacts.add({'name': name, 'phone': phone});
      _nameController.clear();
      _phoneController.clear();
    });
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergencyContacts', jsonEncode(_contacts));
  }
}
  

  Future<bool?> _deleteContact(int index) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('যোগাযোগ মুছবেন?'),
      content: Text('আপনি কি নিশ্চিত যে আপনি ${_contacts[index]['name']} কে মুছে ফেলতে চান?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('বাতিল'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('মুছুন', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    setState(() {
      _contacts.removeAt(index);
    });
    
    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergencyContacts', jsonEncode(_contacts));
    
    return true;
  }
  return false;
}

  Future<void> _callContact(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কল করা যায়নি')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জরুরি যোগাযোগ'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ইনপুট ফিল্ড
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'নাম',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'ফোন নম্বর',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'যোগাযোগ যুক্ত করুন',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            const Text(
              'আপনার জরুরি যোগাযোগসমূহ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // যোগাযোগ তালিকা
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                      child: Text(
                        'এখনো কোনো যোগাযোগ যুক্ত করা হয়নি',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_contacts[index]['phone']!),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) => _deleteContact(index),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteContact(index),
                              ),
                              title: Text(
                                _contacts[index]['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(_contacts[index]['phone']!),
                              trailing: IconButton(
                                icon: const Icon(Icons.call, color: Colors.blue),
                                onPressed: () => _callContact(_contacts[index]['phone']!),
                              ),
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
