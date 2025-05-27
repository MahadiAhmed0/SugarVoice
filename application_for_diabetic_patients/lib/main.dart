import 'package:application_for_diabetic_patients/Home/MedicineLogPage.dart';
import 'package:flutter/material.dart';
import 'Intro/language_selection_page.dart';

import 'Updated_Home/journal_entry.dart';
import 'Updated_Home/Homepage.dart';


void main() => runApp(const HomePageApp());

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