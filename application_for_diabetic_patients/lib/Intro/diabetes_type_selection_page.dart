import 'package:flutter/material.dart';
import '../Home/home_page.dart';

class DiabetesTypeSelectionPage extends StatelessWidget {
  final List<String> types = [
    'Type 1 Diabetic',
    'Type 2A (Insulin)',
    'Type 2B (No insulin)',
    'Prediabetic',
    'Not Sure'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Diabetes Type')),
      body: ListView.builder(
        itemCount: types.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(types[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          ),
        ),
      ),
    );
  }
}
