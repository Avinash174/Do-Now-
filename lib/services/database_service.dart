import 'dart:developer' as dev;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// A provider to fetch user profile details
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    dev.log('userProfileProvider: No logged in user', name: 'database');
    return null;
  }
  dev.log(
    'userProfileProvider: Fetching profile for ${user.uid}',
    name: 'database',
  );
  return await ref.read(databaseServiceProvider).getUserProfile(user.uid);
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

  // ----- Tasks Management -----

  Future<void> addTask({
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
      await newTaskRef.set({
        'id': newTaskRef.key,
        'title': title,
        'description': description,
        'category': category,
        'isCompleted': isCompleted,
        'scheduleTime': scheduleTime,
        'createdAt': ServerValue.timestamp,
      });
      dev.log(
        'DatabaseService: Task added successfully with ID ${newTaskRef.key}',
        name: 'database',
      );
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
}
