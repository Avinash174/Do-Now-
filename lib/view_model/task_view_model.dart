import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum TaskFilter { all, pending, completed, deleted }

// Current filter state
class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void update(TaskFilter filter) => state = filter;
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(
  TaskFilterNotifier.new,
);

// Current search query
class TaskSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final taskSearchProvider = NotifierProvider<TaskSearchNotifier, String>(
  TaskSearchNotifier.new,
);

// Streams live task list from Firebase for the current user
final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  final db = ref.read(databaseServiceProvider);
  return db.watchTasks(user.uid).map((event) {
    if (event.snapshot.value == null) return [];
    try {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries
          .map(
            (e) => TaskModel.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value as Map),
            ),
          )
          .toList()
        ..sort((a, b) => a.scheduleTime.compareTo(b.scheduleTime));
    } catch (e) {
      return [];
    }
  });
});

// Combines tasks, filters, and search query
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final filter = ref.watch(taskFilterProvider);
  final search = ref.watch(taskSearchProvider).toLowerCase();

  return tasks.where((task) {
    // Filter by search query
    final matchesSearch =
        search.isEmpty ||
        task.title.toLowerCase().contains(search) ||
        task.description.toLowerCase().contains(search) ||
        task.category.toLowerCase().contains(search);

    if (filter == TaskFilter.deleted) {
      return task.isDeleted && matchesSearch;
    }
    if (task.isDeleted) return false;

    // Filter by completion status
    final matchesFilter =
        filter == TaskFilter.all ||
        (filter == TaskFilter.completed && task.isCompleted) ||
        (filter == TaskFilter.pending && !task.isCompleted);

    return matchesFilter && matchesSearch;
  }).toList();
});

final taskStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final activeTasks = tasks.where((t) => !t.isDeleted).toList();
  
  final total = activeTasks.length;
  final done = activeTasks.where((t) => t.isCompleted).length;
  final pending = total - done;

  // Group by category
  final Map<String, int> categories = {};
  for (var task in activeTasks) {
    categories[task.category] = (categories[task.category] ?? 0) + 1;
  }

  // Completion rate
  final completionRate = total == 0 ? 0.0 : (done / total);

  return {
    'total': total,
    'done': done,
    'pending': pending,
    'rate': completionRate,
    'categories': categories,
  };
});

class TaskViewModel {
  final DatabaseService _db;
  final NotificationService _notifications;
  final String uid;

  TaskViewModel(this._db, this._notifications, this.uid);

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required DateTime scheduleDate,
    required bool reminderEnabled,
  }) async {
    final taskId = await _db.addTask(
      uid: uid,
      title: title,
      description: description,
      category: category,
      isCompleted: false,
      scheduleTime: scheduleDate.millisecondsSinceEpoch,
    );

    if (taskId != null) {
      final task = TaskModel(
        id: taskId,
        title: title,
        description: description,
        category: category,
        isCompleted: false,
        scheduleTime: scheduleDate.millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      if (reminderEnabled) {
        await _notifications.scheduleTaskNotification(task);
      }
    }
  }

  Future<void> toggleTask(String taskId, TaskModel task) async {
    final newValue = !task.isCompleted;
    await _db.updateTaskStatus(uid: uid, taskId: taskId, isCompleted: newValue);

    if (newValue) {
      // If completed, cancel notification
      await _notifications.cancelTaskNotification(taskId);
    } else {
      // If uncompleted, reschedule notification
      await _notifications.scheduleTaskNotification(
        task.copyWith(isCompleted: false),
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _db.deleteTask(uid: uid, taskId: taskId);
    await _notifications.cancelTaskNotification(taskId);
  }

  Future<void> updateTaskDetails({
    required String taskId,
    required String title,
    required String description,
    required String category,
    required DateTime scheduleDate,
    required bool reminderEnabled,
  }) async {
    await _db.updateTaskDetails(
      uid: uid,
      taskId: taskId,
      title: title,
      description: description,
      category: category,
      scheduleTime: scheduleDate.millisecondsSinceEpoch,
    );

    // Reschedule
    final task = TaskModel(
      id: taskId,
      title: title,
      description: description,
      category: category,
      isCompleted: false,
      scheduleTime: scheduleDate.millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    if (reminderEnabled) {
      await _notifications.scheduleTaskNotification(task);
    } else {
      await _notifications.cancelTaskNotification(taskId);
    }
  }
}

final taskViewModelProvider = Provider<TaskViewModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final db = ref.read(databaseServiceProvider);
  final notifications = ref.read(notificationServiceProvider);
  return TaskViewModel(db, notifications, user.uid);
});
