import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

enum TaskFilter { all, pending, completed }

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
    // Filter by completion status
    final matchesFilter =
        filter == TaskFilter.all ||
        (filter == TaskFilter.completed && task.isCompleted) ||
        (filter == TaskFilter.pending && !task.isCompleted);

    // Filter by search query
    final matchesSearch =
        search.isEmpty ||
        task.title.toLowerCase().contains(search) ||
        task.description.toLowerCase().contains(search) ||
        task.category.toLowerCase().contains(search);

    return matchesFilter && matchesSearch;
  }).toList();
});

// Detailed stats derived from all tasks
final taskStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final total = tasks.length;
  final done = tasks.where((t) => t.isCompleted).length;
  final pending = total - done;

  // Group by category
  final Map<String, int> categories = {};
  for (var task in tasks) {
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

  Future<void> updateTaskDetails({
    required String taskId,
    required String title,
    required String description,
    required String category,
    required DateTime scheduleDate,
  }) async {
    await _db.updateTaskDetails(
      uid: uid,
      taskId: taskId,
      title: title,
      description: description,
      category: category,
      scheduleTime: scheduleDate.millisecondsSinceEpoch,
    );
  }
}

final taskViewModelProvider = Provider<TaskViewModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final db = ref.read(databaseServiceProvider);
  return TaskViewModel(db, user.uid);
});
