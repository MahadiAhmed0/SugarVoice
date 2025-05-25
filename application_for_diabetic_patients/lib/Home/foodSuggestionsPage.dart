import 'package:flutter/material.dart';

class FoodSuggestionPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);
  final List<String> suggestedFoods = [
    'Brown rice with fish and vegetables',
    'Lentil soup with whole wheat bread',
    'Vegetable curry with small portion of rice'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Suggestions'),
        backgroundColor: borderColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Recommended meals:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...suggestedFoods.map((food) => ListTile(
                  leading: Icon(Icons.restaurant, color: Colors.green),
                  title: Text(food),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}