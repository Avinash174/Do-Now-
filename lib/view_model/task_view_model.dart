import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// Streams live task list from Firebase for the current user
final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  final db = ref.read(databaseServiceProvider);
  return db.watchTasks(user.uid).map((event) {
    if (event.snapshot.value == null) return [];
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    return data.entries
        .map(
          (e) => TaskModel.fromMap(
            e.key.toString(),
            Map<dynamic, dynamic>.from(e.value as Map),
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  });
});

// Computed stats derived from the tasks list
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final total = tasks.length;
  final done = tasks.where((t) => t.isCompleted).length;
  return {'total': total, 'done': done, 'pending': total - done};
});

class TaskViewModel {
  final DatabaseService _db;
  final String uid;

  TaskViewModel(this._db, this.uid);

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required DateTime scheduleDate,
  }) async {
    await _db.addTask(
      uid: uid,
      title: title,
      description: description,
      category: category,
      isCompleted: false,
      scheduleTime: scheduleDate.millisecondsSinceEpoch,
    );
  }

  Future<void> toggleTask(String taskId, bool currentValue) async {
    await _db.updateTaskStatus(
      uid: uid,
      taskId: taskId,
      isCompleted: !currentValue,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _db.deleteTask(uid: uid, taskId: taskId);
  }
}

final taskViewModelProvider = Provider<TaskViewModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final db = ref.read(databaseServiceProvider);
  return TaskViewModel(db, user.uid);
});
