import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signUpWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    dev.log(
      'AuthService: Starting signUpWithEmailPassword for $email',
      name: 'auth',
    );
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      dev.log('AuthService: Firebase user created successfully', name: 'auth');

      // Save user profile info in Realtime Database
      if (credential.user != null) {
        dev.log('AuthService: Creating user profile in DB', name: 'auth');
        await DatabaseService().createUserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
        );
      }

      return credential;
    } catch (e) {
      dev.log(
        'AuthService: Error in signUpWithEmailPassword: $e',
        name: 'auth',
        error: e,
      );
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    dev.log(
      'AuthService: Starting signInWithEmailPassword for $email',
      name: 'auth',
    );
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      dev.log('AuthService: Login successful for $email', name: 'auth');
      return credential;
    } catch (e) {
      dev.log(
        'AuthService: Error in signInWithEmailPassword: $e',
        name: 'auth',
        error: e,
      );
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    dev.log('AuthService: Starting signInWithGoogle', name: 'auth');
    try {
      dev.log('AuthService: Triggering GoogleSignIn.signIn()', name: 'auth');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        dev.log(
          'AuthService: Google Sign-In was cancelled by user',
          name: 'auth',
        );
        return null;
      }

      dev.log('AuthService: Google User: ${googleUser.email}', name: 'auth');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      dev.log('AuthService: Google Auth tokens obtained', name: 'auth');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      dev.log(
        'AuthService: Signing in to Firebase with credentials',
        name: 'auth',
      );
      final userCredential = await _auth.signInWithCredential(credential);

      dev.log('AuthService: Firebase Google login success', name: 'auth');

      // Save user profile info if it's a new user
      if (userCredential.user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        dev.log(
          'AuthService: New Google user, creating database profile',
          name: 'auth',
        );
        await DatabaseService().createUserProfile(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
        );
      }

      return userCredential;
    } catch (e) {
      dev.log(
        'AuthService: Error in signInWithGoogle: $e',
        name: 'auth',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    dev.log('AuthService: Sending password reset to $email', name: 'auth');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      dev.log('AuthService: Password reset email sent', name: 'auth');
    } catch (e) {
      dev.log(
        'AuthService: Error in sendPasswordResetEmail: $e',
        name: 'auth',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    dev.log('AuthService: User logging out', name: 'auth');
    await _googleSignIn.signOut();
    await _auth.signOut();
    dev.log('AuthService: Logged out successfully', name: 'auth');
  }

  User? get currentUser => _auth.currentUser;
}
