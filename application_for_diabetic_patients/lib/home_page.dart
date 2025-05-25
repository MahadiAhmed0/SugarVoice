import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<String> buttons = [
    'Check Sugar',
    'Take/Log Medicine',
    'Food Advice',
    'Call Family',
    'Offline Diary'
  ];

  final Color borderColor = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: borderColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: buttons
                  .map((label) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Center(
                              child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: borderColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: borderColor,
                child: Icon(Icons.mic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
