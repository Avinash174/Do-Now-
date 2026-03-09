class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isCompleted;
  final int scheduleTime;
  final int createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.scheduleTime,
    required this.createdAt,
  });

  factory TaskModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      scheduleTime: map['scheduleTime'] ?? 0,
      createdAt: map['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'scheduleTime': scheduleTime,
      'createdAt': createdAt,
    };
  }

  TaskModel copyWith({bool? isCompleted}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduleTime: scheduleTime,
      createdAt: createdAt,
    );
  }

  String get formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(scheduleTime);
    final now = DateTime.now();
    final diff = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    final time =
        '${date.hour > 12 ? date.hour - 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';

    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Tomorrow, $time';
    if (diff == -1) return 'Yesterday, $time';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, $time';
  }
}
