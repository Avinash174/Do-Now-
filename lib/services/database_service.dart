import 'dart:developer' as dev;
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// A provider to fetch user profile details in real-time
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    dev.log('userProfileProvider: No logged in user', name: 'database');
    return Stream.value(null);
  }
  dev.log(
    'userProfileProvider: Watching profile for ${user.uid}',
    name: 'database',
  );
  return ref.read(databaseServiceProvider).watchUserProfile(user.uid);
});

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ----- Users Management -----

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    dev.log('DatabaseService: Creating profile for $uid', name: 'database');
    try {
      await _db.child('users/$uid/profile').set({
        'name': name,
        'email': email,
        'createdAt': ServerValue.timestamp,
      });
      dev.log(
        'DatabaseService: Profile created successfully',
        name: 'database',
      );
    } catch (e) {
      dev.log(
        'DatabaseService: Error in createUserProfile: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    dev.log('DatabaseService: Getting profile for $uid', name: 'database');
    try {
      final snapshot = await _db.child('users/$uid/profile').get();
      if (snapshot.exists) {
        dev.log('DatabaseService: Profile found', name: 'database');
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      dev.log('DatabaseService: No profile found for $uid', name: 'database');
      return null;
    } catch (e) {
      dev.log(
        'DatabaseService: Error in getUserProfile: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _db.child('users/$uid/profile').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    });
  }

  Future<void> updateUserName(String uid, String name) async {
    dev.log(
      'DatabaseService: Updating name for $uid to $name',
      name: 'database',
    );
    try {
      await _db.child('users/$uid/profile').update({'name': name});
      dev.log('DatabaseService: Name updated successfully', name: 'database');
    } catch (e) {
      dev.log(
        'DatabaseService: Error in updateUserName: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> uploadProfilePhoto(String uid, File imageFile) async {
    dev.log(
      'DatabaseService: Uploading profile photo for $uid',
      name: 'database',
    );

    if (!await imageFile.exists()) {
      dev.log(
        'DatabaseService: Error - Image file does not exist at ${imageFile.path}',
        name: 'database',
      );
      throw Exception('Image file does not exist');
    }

    try {
      final storage = FirebaseStorage.instance;

      // Get the bucket name for debugging
      dev.log(
        'DatabaseService: Storage bucket: ${storage.bucket ?? "default"}',
        name: 'database',
      );

      final storageRef = storage.ref();
      final profilePhotoRef = storageRef.child(
        'profile_photos/$uid/profile.jpg',
      );

      dev.log(
        'DatabaseService: Starting profile photo upload to ${profilePhotoRef.fullPath}',
        name: 'database',
      );

      final uploadTask = profilePhotoRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to progress for better debugging
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        dev.log(
          'DatabaseService: Upload Progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes (${snapshot.state})',
          name: 'database',
        );
      });

      final snapshot = await uploadTask;
      dev.log(
        'DatabaseService: Upload completed with state: ${snapshot.state}',
        name: 'database',
      );

      if (snapshot.state == TaskState.success) {
        dev.log('DatabaseService: Fetching download URL...', name: 'database');
        final downloadUrl = await profilePhotoRef.getDownloadURL();
        dev.log(
          'DatabaseService: Download URL obtained successfully',
          name: 'database',
        );

        // Save the photo URL to database
        await _db.child('users/$uid/profile').update({
          'photoUrl': downloadUrl,
          'photoUpdatedAt': ServerValue.timestamp,
        });

        dev.log(
          'DatabaseService: Profile photo uploaded and DB updated successfully',
          name: 'database',
        );
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      dev.log(
        'DatabaseService: Firebase Error in uploadProfilePhoto: [${e.code}] ${e.message}',
        name: 'database',
        error: e,
      );

      if (e.code == 'object-not-found') {
        dev.log(
          'DatabaseService: CRITICAL - object-not-found error detected. This means:',
          name: 'database',
        );
        dev.log(
          '1. Firebase Storage bucket may not be initialized in Firebase Console',
          name: 'database',
        );
        dev.log(
          '2. Storage bucket reference path may be incorrect',
          name: 'database',
        );
        dev.log(
          '3. Bucket may not have proper CORS/access rules configured',
          name: 'database',
        );
        dev.log(
          'SOLUTION: Go to Firebase Console > Storage > "Get Started" to initialize the bucket',
          name: 'database',
        );
        throw Exception(
          'Firebase Storage bucket not initialized. Solution: Open Firebase Console > Storage tab > Click "Get Started" button to initialize Cloud Storage.',
        );
      }

      if (e.code == 'permission-denied') {
        dev.log(
          'DatabaseService: Storage permission denied. Check Firebase Storage rules in Console.',
          name: 'database',
        );
        throw Exception(
          'Firebase Storage permission denied. Check your storage rules in Firebase Console.',
        );
      }

      rethrow;
    } catch (e) {
      dev.log(
        'DatabaseService: Unexpected error in uploadProfilePhoto: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  // ----- Tasks Management -----

  Future<String?> addTask({
    required String uid,
    required String title,
    required String description,
    required String category,
    required bool isCompleted,
    required int scheduleTime, // Epoch timestamp in ms
  }) async {
    dev.log('DatabaseService: Adding task for $uid: $title', name: 'database');
    try {
      final newTaskRef = _db.child('users/$uid/tasks').push();
      final taskId = newTaskRef.key;
      await newTaskRef.set({
        'id': taskId,
        'title': title,
        'description': description,
        'category': category,
        'isCompleted': isCompleted,
        'scheduleTime': scheduleTime,
        'createdAt': ServerValue.timestamp,
      });

      // Store taskId locally as requested
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_task_id', taskId ?? '');

      dev.log(
        'DatabaseService: Task added successfully with ID $taskId and saved to SharedPreferences',
        name: 'database',
      );
      return taskId;
    } catch (e) {
      dev.log(
        'DatabaseService: Error in addTask: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Stream<DatabaseEvent> watchTasks(String uid) {
    dev.log('DatabaseService: Starting task stream for $uid', name: 'database');
    return _db.child('users/$uid/tasks').onValue;
  }

  Future<void> updateTaskStatus({
    required String uid,
    required String taskId,
    required bool isCompleted,
  }) async {
    dev.log(
      'DatabaseService: Updating task $taskId status to $isCompleted',
      name: 'database',
    );
    try {
      await _db.child('users/$uid/tasks/$taskId').update({
        'isCompleted': isCompleted,
      });
      dev.log('DatabaseService: Task status updated', name: 'database');
    } catch (e) {
      dev.log(
        'DatabaseService: Error in updateTaskStatus: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> updateTaskDetails({
    required String uid,
    required String taskId,
    required String title,
    required String description,
    required String category,
    required int scheduleTime,
  }) async {
    dev.log(
      'DatabaseService: Updating details for task $taskId',
      name: 'database',
    );
    try {
      await _db.child('users/$uid/tasks/$taskId').update({
        'title': title,
        'description': description,
        'category': category,
        'scheduleTime': scheduleTime,
      });
      dev.log('DatabaseService: Task details updated', name: 'database');
    } catch (e) {
      dev.log(
        'DatabaseService: Error in updateTaskDetails: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    dev.log(
      'DatabaseService: Deleting task $taskId for $uid',
      name: 'database',
    );
    try {
      await _db.child('users/$uid/tasks/$taskId').remove();
      dev.log('DatabaseService: Task deleted successfully', name: 'database');
    } catch (e) {
      dev.log(
        'DatabaseService: Error in deleteTask: $e',
        name: 'database',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> saveFCMToken(String uid, String token) async {
    dev.log('DatabaseService: Saving FCM token for $uid', name: 'database');
    try {
      await _db.child('users/$uid/profile').update({
        'fcmToken': token,
        'tokenUpdatedAt': ServerValue.timestamp,
      });
      dev.log('DatabaseService: FCM token saved', name: 'database');
    } catch (e) {
      dev.log(
        'DatabaseService: Error saving FCM token: $e',
        name: 'database',
        error: e,
      );
    }
  }
}
