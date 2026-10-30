import '../models/task.dart';

class TaskManagement {
  TaskManagement._();

  static TaskPriority priorityFor(Task task, {DateTime? now}) {
    if (task.isCompleted) return TaskPriority.normal;

    final timeUntilDeadline = task.deadline.difference(now ?? DateTime.now());
    if (timeUntilDeadline.isNegative ||
        timeUntilDeadline <= const Duration(hours: 24)) {
      return TaskPriority.high;
    }
    if (timeUntilDeadline <= const Duration(days: 3)) {
      return TaskPriority.medium;
    }
    return TaskPriority.normal;
  }

  static List<Task> filterAndSort(
    Iterable<Task> tasks, {
    String? course,
    bool? isCompleted,
  }) {
    final filtered = tasks.where((task) {
      return (course == null || task.course == course) &&
          (isCompleted == null || task.isCompleted == isCompleted);
    }).toList()
      ..sort((first, second) => first.deadline.compareTo(second.deadline));
    return filtered;
  }
}
