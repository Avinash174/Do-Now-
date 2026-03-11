import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to save session locally
  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session_id', uid);
    dev.log('AuthService: Session saved for UID: $uid', name: 'auth');
  }

  // Helper to clear session locally
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session_id');
    dev.log('AuthService: Session cleared', name: 'auth');
  }

  Future<UserCredential?> signUpWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    dev.log(
      'AuthService: Starting signUpWithEmailPassword for $cleanEmail',
      name: 'auth',
    );
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
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
        // Store session in SharedPreferences as requested
        await _saveSession(credential.user!.uid);
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
    final cleanEmail = email.trim().toLowerCase();
    dev.log(
      'AuthService: Starting signInWithEmailPassword for $cleanEmail',
      name: 'auth',
    );
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      dev.log('AuthService: Login successful for $email', name: 'auth');

      if (credential.user != null) {
        // Store session in SharedPreferences as requested
        await _saveSession(credential.user!.uid);
      }

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
    try {
      await _auth.signOut().timeout(const Duration(seconds: 3));
    } catch (e) {
      dev.log('AuthService: Error signing out of Firebase: $e', name: 'auth', error: e);
    }
    // Clear local session as requested
    await _clearSession();
    dev.log('AuthService: Logged out successfully', name: 'auth');
  }

  Future<void> updateEmail(String newEmail) async {
    final cleanEmail = newEmail.trim().toLowerCase();
    dev.log('AuthService: Updating email to $cleanEmail', name: 'auth');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(cleanEmail);
        dev.log('AuthService: Verification email sent for new email', name: 'auth');
      }
    } catch (e) {
      dev.log('AuthService: Error in updateEmail: $e', name: 'auth', error: e);
      rethrow;
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    dev.log('AuthService: Starting reauthentication for $cleanEmail', name: 'auth');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: cleanEmail,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        dev.log('AuthService: Re-authentication successful', name: 'auth');
      }
    } catch (e) {
      dev.log('AuthService: Error in reauthenticate: $e', name: 'auth', error: e);
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    dev.log('AuthService: Updating password', name: 'auth');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        dev.log('AuthService: Password updated successfully', name: 'auth');
      }
    } catch (e) {
      dev.log('AuthService: Error in updatePassword: $e', name: 'auth', error: e);
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
}
