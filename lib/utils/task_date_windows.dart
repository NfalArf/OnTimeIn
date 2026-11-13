import '../models/task.dart';

class TaskDateWindows {
  TaskDateWindows._();

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime weekStart(DateTime value) {
    final date = dateOnly(value);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  static List<Task> dueToday(Iterable<Task> tasks, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    return tasks
        .where((task) => !task.isCompleted && dateOnly(task.deadline) == today)
        .toList()
      ..sort((first, second) => first.deadline.compareTo(second.deadline));
  }

  static List<Task> dueThisWeek(Iterable<Task> tasks, {DateTime? now}) {
    final start = weekStart(now ?? DateTime.now());
    final end = start.add(const Duration(days: 7));
    return tasks.where((task) {
        final dueDate = dateOnly(task.deadline);
        return !task.isCompleted &&
            !dueDate.isBefore(start) &&
            dueDate.isBefore(end);
      }).toList()
      ..sort((first, second) => first.deadline.compareTo(second.deadline));
  }
}
