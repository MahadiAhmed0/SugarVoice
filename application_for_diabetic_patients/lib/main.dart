import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Authentication/RegistrationPage.dart';
import 'Intro/language_selection_page.dart';
import 'Updated_Home/journal_entry.dart';
import 'Updated_Home/Homepage.dart';
import 'Updated_Home/medicine_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(HomePageApp());
}

class DiabetesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes App',
      debugShowCheckedModeBanner: false,
      home: HomePageApp(),
    );
  }
}


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Make sure Firebase is initialized
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: RegisterPage(),
//   ));
// }