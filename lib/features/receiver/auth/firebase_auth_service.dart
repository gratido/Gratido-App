import 'dart:convert'; 
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; 
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
  }
  Future<void> _handleToken(User? user) async {
    if (user != null) {
      final idToken = await user.getIdToken(true);
      if (idToken != null) {
        // Copy to clipboard so you can paste directly into Postman
        await Clipboard.setData(ClipboardData(text: idToken));

        print("-----------------------------------------");
        print("AUTH SUCCESS!");
        print("TOKEN COPIED TO CLIPBOARD.");
        print("Paste it into Postman now (Ctrl + V).");
        print("-----------------------------------------");
      }
    }
  }

  // The logic that actually creates the row in Supabase
  Future<void> _syncWithBackend(User? user, String role) async {
    if (user == null) return;

    // If you are on a different Wi-Fi, this might have changed!
    const String currentLaptopIp = "192.168.0.5";

    try {
      final token = await user.getIdToken(true);
      final response = await http
          .post(
            Uri.parse('http://$currentLaptopIp:5227/api/auth/register'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'role': role}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Supabase Sync Success for ${user.email}");
      } else {
        print("❌ Supabase Sync Rejected: ${response.body}");
      }
    } catch (e) {
      print("❌ Connection to Laptop Failed: $e. Is your Backend running (F5)?");
    }
  }

  // ✨ EMAIL SIGNUP
  Future<User?> signup(
  String email,
  String password,
  String role,
  String fullName,
) async {
  try {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;

    if (user != null) {

      // ✅ SET DISPLAY NAME
      await user.updateDisplayName(fullName);

      // ✅ Reload to refresh currentUser
      await user.reload();

      // 🔥 Run backend sync (no await = faster UI)
      _syncWithBackend(user, role);

      await _handleToken(user);
    }

    return user;

  } on FirebaseAuthException catch (e) {
    print('🔥 Firebase Signup Error [${e.code}]: ${e.message}');
    return null;
  } catch (e) {
    print('🔥 Unknown Signup Error: $e');
    return null;
  }
}


  // ✨ EMAIL LOGIN (Updated with Role and Sync)
  Future<User?> login(String email, String password, String role) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _syncWithBackend(userCredential.user, role);
      await _handleToken(userCredential.user);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('🔥 Login Failed [${e.code}]: ${e.message}');
      return null;
    }
  }

  // ✨ GOOGLE LOGIN – updated for google_sign_in ^7.x
  // ✨ GOOGLE LOGIN – Updated to sync with Supabase while keeping v7 logic intact
  Future<User?> googleLogin(String role) async {
    try {
      // 1. Make sure GoogleSignIn is initialized (required in v7)
      await _ensureGoogleInitialized();

      // 2. v7: use `authenticate()` as in your working code
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: const <String>['email'],
      );

      // 3. v7: authentication is synchronous (no await)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        print('Google Login Error: Missing idToken');
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign into Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // 🚀 5. SUPABASE SYNC: This is the magic update!
      // It ensures Google users are added to your database automatically.
      await _syncWithBackend(userCredential.user, role);

      // 6. Handle token for Postman (Your existing logic)
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
