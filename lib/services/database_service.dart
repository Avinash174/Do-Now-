import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// A provider to fetch user profile details
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
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
    await _db.child('users/$uid/profile').set({
      'name': name,
      'email': email,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _db.child('users/$uid/profile').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
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
  }

  Stream<DatabaseEvent> watchTasks(String uid) {
    return _db.child('users/$uid/tasks').onValue;
  }

  Future<void> updateTaskStatus({
    required String uid,
    required String taskId,
    required bool isCompleted,
  }) async {
    await _db.child('users/$uid/tasks/$taskId').update({
      'isCompleted': isCompleted,
    });
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    await _db.child('users/$uid/tasks/$taskId').remove();
  }
}
