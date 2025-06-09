import 'package:application_for_diabetic_patients/Authentication/login_page.dart';
import 'package:application_for_diabetic_patients/Constansts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'Updated_Home/Homepage.dart';


void main() async {
  Gemini.init(apiKey: Gemini_API_KEY);
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Initialize Firebase
  runApp(DiabetesApp());
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