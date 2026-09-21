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
  final String deadline;
  final TaskPriority priority;
  final bool isCompleted;

  Task copyWith({bool? isCompleted}) {
    return Task(
      title: title,
      course: course,
      deadline: deadline,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
