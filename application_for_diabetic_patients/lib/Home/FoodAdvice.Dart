import 'package:flutter/material.dart';
import 'FoodSelection.dart';  
import 'FoodSuggestionsPage.dart'; 

class FoodAdvicePage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);
  final List<String> foodCategories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Advice'),
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
              'What did you eat?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodCategories.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(foodCategories[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                        // Voice input for food
                      },
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FoodSelectionPage(mealType: foodCategories[index])));
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Or get food suggestions based on your sugar level',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FoodSuggestionPage()));
            },
            child: Text('Get Suggestions'),
          ),
          SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Voice command functionality
        },
        backgroundColor: borderColor,
        child: Icon(Icons.mic),
      ),
    );
  }
}