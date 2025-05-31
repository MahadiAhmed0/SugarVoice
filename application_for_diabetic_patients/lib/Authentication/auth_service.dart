import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
 
  Future<User?> createWithEmailAndPassword(String email, String password) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return credential.user;
  } catch (e) {
    log("Registration error: ${e.toString()}");
    return null;
  }
  
}

Future<User?> signInUserWithEmailAndPassword(String email, String password) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  } catch (e) {
    log("Login error: ${e.toString()}");
    return null;
  }
}

Future<void> signout() async {
  try {
    await _auth.signOut();
  } catch (e) {
    log("Signout error: ${e.toString()}");
  }
}
}