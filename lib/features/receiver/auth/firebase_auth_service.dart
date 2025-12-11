import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // v7: use the singleton instance instead of `GoogleSignIn(...)`
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize(
          // If you ever need extra scopes or serverClientId, pass them here.
          // scopes: <String>['email'],
          );
      _isGoogleInitialized = true;
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

      // v7: use `authenticate()` instead of `signIn()`
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        // Optional: hint scopes if you need more than basic sign-in
        scopeHint: const <String>['email'],
      );

      // v7: `authentication` is now synchronous, and `accessToken` is gone.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        print('Google Login Error: Missing idToken');
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken is no longer on GoogleSignInAuthentication in v7.
        // It is NOT required for Firebase sign-in; idToken is enough.
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } on GoogleSignInException catch (e) {
      // Specific Google sign-in error info
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
