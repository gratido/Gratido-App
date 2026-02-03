// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // ✅ Added for Clipboard functionality

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // v7: use the singleton instance instead of `GoogleSignIn(...)`
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
  }

  // ✅ Helper method to get token and copy to clipboard without breaking logic
  Future<void> _handleToken(User? user) async {
    if (user != null) {
      final idToken = await user.getIdToken(true);
      if (idToken != null) {
        // Copy to clipboard so you can paste directly into Postman
        await Clipboard.setData(ClipboardData(text: idToken));

        print("-----------------------------------------");
        print("✅ AUTH SUCCESS!");
        print("TOKEN COPIED TO CLIPBOARD.");
        print("Paste it into Postman now (Ctrl + V).");
        print("-----------------------------------------");
      }
    }
  }

  // ✨ EMAIL SIGNUP
  Future<User?> signup(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Handle token for Postman
      await _handleToken(userCredential.user);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Signup error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('Signup error (unknown): $e');
      return null;
    }
  }

  // ✨ EMAIL LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Handle token for Postman
      await _handleToken(userCredential.user);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('Login error (unknown): $e');
      return null;
    }
  }

  // ✨ GOOGLE LOGIN – updated for google_sign_in ^7.x
  Future<User?> googleLogin() async {
    try {
      // Make sure GoogleSignIn is initialized (required in v7)
      await _ensureGoogleInitialized();

      // v7: use `authenticate()` as in your working code
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: const <String>['email'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        print('Google Login Error: Missing idToken');
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Handle token for Postman
      await _handleToken(userCredential.user);

      return userCredential.user;
    } on GoogleSignInException catch (e) {
      print(
          'Google Sign-In error: code=${e.code.name}, description=${e.description}, details=${e.details}');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Google Login FirebaseAuthException [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('Google Login Error (unknown): $e');
      return null;
    }
  }

  // ✨ FORGOT PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ✨ LOGOUT
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
