import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/task.dart';
import 'package:nama_project/utils/reminder_planner.dart';
import 'package:nama_project/utils/task_date_windows.dart';

Task _task(int id, DateTime deadline, {bool completed = false}) => Task(
  id: id,
  title: 'Task $id',
  course: 'Basis Data',
  deadline: deadline,
  priority: TaskPriority.normal,
  isCompleted: completed,
);

void main() {
  test('deadline plan skips past reminders and keeps future H-1 and H', () {
    final now = DateTime(2026, 11, 14, 10);
    final reminders = ReminderPlanner.deadlineReminderTimes(
      DateTime(2026, 11, 16, 23, 59),
      now: now,
    );

    expect(reminders, [DateTime(2026, 11, 15, 9), DateTime(2026, 11, 16, 9)]);
  });

  test('daily plans cover only active tasks in the current and next week', () {
    final now = DateTime(2026, 11, 14, 8);
    final tasks = [
      _task(1, DateTime(2026, 11, 14, 23, 59)),
      _task(2, DateTime(2026, 11, 16, 23, 59)),
      _task(3, DateTime(2026, 11, 17), completed: true),
      _task(4, DateTime(2026, 11, 23)),
      _task(5, DateTime(2026, 11, 6)),
    ];

    final plans = ReminderPlanner.dailyPlans(tasks, now: now);
    final todayPlan = plans.first;
    expect(todayPlan.date, DateTime(2026, 11, 14));
    expect(todayPlan.tasksDueToday, 1);
    expect(todayPlan.tasksDueThisWeek, 1);
    expect(plans.any((plan) => plan.date == DateTime(2026, 11, 15)), isTrue);
    expect(plans.any((plan) => plan.date == DateTime(2026, 11, 16)), isTrue);
    expect(plans.any((plan) => plan.date == DateTime(2026, 11, 23)), isFalse);
    expect(
      TaskDateWindows.dueThisWeek(tasks, now: now).map((task) => task.id),
      [1],
    );
  });

  test(
    'daily plans are empty when there are no active tasks in scheduled weeks',
    () {
      final now = DateTime(2026, 11, 14, 8);
      final plans = ReminderPlanner.dailyPlans([
        _task(1, DateTime(2026, 11, 14), completed: true),
        _task(2, DateTime(2026, 11, 6)),
      ], now: now);

      expect(plans, isEmpty);
    },
  );
}
