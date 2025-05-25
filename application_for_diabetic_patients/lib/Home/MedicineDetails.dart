import 'package:flutter/material.dart';
class MedicineDetailsPage extends StatelessWidget {
  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
        backgroundColor: borderColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    // Voice input for medicine name
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    // Voice input for dosage
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    // Voice input for time
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                // Save medicine details
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
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