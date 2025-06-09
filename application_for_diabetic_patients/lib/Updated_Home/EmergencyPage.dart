import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Map<String, String>> _contacts = [];

  void _addContact() async {
  final name = _nameController.text;
  final phone = _phoneController.text;
  if (name.isNotEmpty && phone.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing contacts
    final String? contactsJsonString = prefs.getString('emergencyContacts');
    List<Map<String, String>> contacts = [];
    
    if (contactsJsonString != null && contactsJsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(contactsJsonString);
      contacts = jsonList.map((json) => {
        'name': json['name'] as String,
        'phone': json['phone'] as String
      }).toList();
    }
    
    // Add new contact
    contacts.add({'name': name, 'phone': phone});
    
    // Save back to SharedPreferences
    await prefs.setString('emergencyContacts', jsonEncode(contacts));
    
    setState(() {
      _contacts.add({'name': name, 'phone': phone});
      _nameController.clear();
      _phoneController.clear();
    });
  }
}

// Modify the _deleteContact method to update SharedPreferences
Future<bool?> _deleteContact(int index) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Contact'),
      content: Text('Are you sure you want to delete ${_contacts[index]['name']}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergencyContacts', jsonEncode(_contacts));
    setState(() {
      _contacts.removeAt(index);
    });
    return true;
  }
  return false;
}


  Future<void> _callContact(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not place call')),
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
        _contacts = jsonList.map((json) => {
          'name': json['name'] as String,
          'phone': json['phone'] as String
        }).toList();
      });
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Contact', 
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            const Text(
              'Your Emergency Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Contacts list with call and delete options
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                      child: Text(
                        'No contacts added yet',
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
                                icon: const Icon(Icons.call, color: Colors.red),
                                onPressed: () => _callContact(_contacts[index]['phone']!) ,
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