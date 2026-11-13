import '../models/task.dart';
import 'task_date_windows.dart';

class DailyReminderPlan {
  const DailyReminderPlan({
    required this.date,
    required this.tasksDueToday,
    required this.tasksDueThisWeek,
  });

  final DateTime date;
  final int tasksDueToday;
  final int tasksDueThisWeek;
}

class ReminderPlanner {
  ReminderPlanner._();

  static List<DateTime> deadlineReminderTimes(
    DateTime deadline, {
    required DateTime now,
  }) {
    final deadlineDate = TaskDateWindows.dateOnly(deadline);
    return [
          deadlineDate.subtract(const Duration(days: 3)),
          deadlineDate.subtract(const Duration(days: 1)),
          deadlineDate,
        ]
        .map((date) => DateTime(date.year, date.month, date.day, 9))
        .where((date) => date.isAfter(now))
        .toList();
  }

  static List<DailyReminderPlan> dailyPlans(
    Iterable<Task> tasks, {
    required DateTime now,
  }) {
    final today = TaskDateWindows.dateOnly(now);
    final endDate = TaskDateWindows.weekStart(today)
        .add(const Duration(days: 13));
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
    final plans = <DailyReminderPlan>[];

    for (
      var day = today;
      !day.isAfter(endDate);
      day = day.add(const Duration(days: 1))
    ) {
      final weekStart = TaskDateWindows.weekStart(day);
      final weekEnd = weekStart.add(const Duration(days: 7));
      final tasksThisWeek = activeTasks.where((task) {
        final dueDate = TaskDateWindows.dateOnly(task.deadline);
        return !dueDate.isBefore(weekStart) && dueDate.isBefore(weekEnd);
      }).toList();
      final reminderTime = DateTime(day.year, day.month, day.day, 9);

      if (tasksThisWeek.isEmpty || !reminderTime.isAfter(now)) continue;

      final tasksToday = tasksThisWeek.where(
        (task) => TaskDateWindows.dateOnly(task.deadline) == day,
      );
      plans.add(
        DailyReminderPlan(
          date: day,
          tasksDueToday: tasksToday.length,
          tasksDueThisWeek: tasksThisWeek.length,
        ),
      );
    }

    return plans;
  }
}
