
enum TaskPriority { high, medium, normal }

class Task {
  const Task({
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });

  final String title;
  final String course;
  final DateTime deadline;
  final TaskPriority priority;
  final bool isCompleted;

  Task copyWith({
    String? title,
    String? course,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
