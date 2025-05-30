import 'package:flutter/material.dart';
import '../Authentication/login_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
              child: Text('বাংলা'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
              child: Text('English'),
            ),
          ],
        ),
      ),
    );
  }
}
