import '../models/task.dart';

class TaskRepository {
  // Data dummy sementara untuk latihan.
  static const List<Task> _tasks = [
    Task(
      title: 'Mobile Programming Assignment',
      course: 'Pemrograman Mobile',
      deadline: 'Tomorrow, 23:59',
      priority: TaskPriority.high,
    ),
    Task(
      title: 'Database Report',
      course: 'Basis Data',
      deadline: '25 Sep, 23:59',
      priority: TaskPriority.medium,
    ),
    Task(
      title: 'Read Chapter 4 and make notes',
      course: 'Human Computer Interaction',
      deadline: '27 Sep, 10:00',
      priority: TaskPriority.normal,
    ),
    Task(
      title: 'Group presentation outline',
      course: 'Software Engineering',
      deadline: '30 Sep, 16:00',
      priority: TaskPriority.normal,
      isCompleted: true,
    ),
  ];

  // Mengambil data dummy seperti simulasi mengambil data dari server.
  Future<List<Task>> fetchTasks({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));

    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }

    return _tasks;
  }
}