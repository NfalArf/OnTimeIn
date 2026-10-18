
import '../models/task.dart';

class TaskRepository {
  static final List<Task> _tasks = [
    Task(
      title: 'Mobile Programming Assignment',
      course: 'Pemrograman Mobile',
      deadline: DateTime(2026, 10, 20, 23, 59),
      priority: TaskPriority.high,
    ),
    Task(
      title: 'Database Report',
      course: 'Basis Data',
      deadline: DateTime(2026, 10, 25, 23, 59),
      priority: TaskPriority.medium,
    ),
    Task(
      title: 'Read Chapter 4 and make notes',
      course: 'Human Computer Interaction',
      deadline: DateTime(2026, 10, 27, 10),
      priority: TaskPriority.normal,
    ),
    Task(
      title: 'Group presentation outline',
      course: 'Software Engineering',
      deadline: DateTime(2026, 10, 30, 16),
      priority: TaskPriority.normal,
      isCompleted: true,
    ),
  ];

  Future<List<Task>> fetchTasks({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (simulateError) {
      throw Exception('Gagal memuat data tugas.');
    }

    return List<Task>.of(_tasks);
  }
}
