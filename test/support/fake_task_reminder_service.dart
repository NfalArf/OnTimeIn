import 'package:nama_project/models/task.dart';
import 'package:nama_project/services/notification_service.dart';

class FakeTaskReminderService implements TaskReminderService {
  @override
  bool notificationsEnabled = true;

  final List<Task> syncedTasks = [];
  final List<int> cancelledTaskIds = [];
  int dailyRefreshCount = 0;
  List<Task> lastDailyTasks = [];

  @override
  Future<void> cancelReminders(int taskId) async {
    cancelledTaskIds.add(taskId);
  }

  @override
  Future<void> refreshDailyReminders(List<Task> tasks) async {
    dailyRefreshCount++;
    lastDailyTasks = List.of(tasks);
  }

  @override
  Future<void> syncTaskReminders(Task task) async {
    if (task.isCompleted) {
      await cancelReminders(task.id);
    } else {
      syncedTasks.add(task);
    }
  }
}
