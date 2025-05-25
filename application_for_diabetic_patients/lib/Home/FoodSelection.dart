import 'package:flutter/material.dart';

class FoodSelectionPage extends StatelessWidget {
  final String mealType;
  final Color borderColor = Color(0xFF4B0082);
  final List<String> commonFoods = ['Rice', 'Fish', 'Vegetables', 'Lentils', 'Egg', 'Bread'];

  FoodSelectionPage({required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select $mealType Items'),
        backgroundColor: borderColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select what you ate for $mealType',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: commonFoods.map((food) {
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 40),
                      Text(food),
                      IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}