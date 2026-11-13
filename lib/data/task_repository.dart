import '../models/task.dart';
import 'app_data_repository.dart';

class TaskRepository {
  TaskRepository({AppDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? AppDataRepository.instance;

  final AppDataRepository _dataRepository;

  Future<List<Task>> fetchTasks({bool simulateError = false}) async {
    if (simulateError) {
      throw Exception('Gagal memuat data tugas.');
    }
    return _dataRepository.fetchTasks();
  }

  Future<Task> addTask(Task task) => _dataRepository.addTask(task);

  Future<void> updateTask(Task task) => _dataRepository.updateTask(task);

  Future<void> deleteTask(int id) => _dataRepository.deleteTask(id);
}
