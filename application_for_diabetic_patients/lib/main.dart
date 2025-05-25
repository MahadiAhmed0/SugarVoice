import 'package:flutter/material.dart';
import 'Intro/language_selection_page.dart';

void main() => runApp(DiabetesApp());

class DiabetesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes App',
      debugShowCheckedModeBanner: false,
      home: LanguageSelectionPage(),
    );
  }
}
