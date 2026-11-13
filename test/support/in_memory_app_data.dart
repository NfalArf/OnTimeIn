import 'package:nama_project/data/app_data_repository.dart';
import 'package:nama_project/models/course.dart';
import 'package:nama_project/models/task.dart';

class InMemoryAppData {
  InMemoryAppData._({
    List<Task>? initialTasks,
    List<Course>? initialCourses,
  }) : repository = _InMemoryAppDataRepository(
         initialTasks: initialTasks,
         initialCourses: initialCourses,
       );

  final AppDataRepository repository;

  static InMemoryAppData create({
    List<Task>? initialTasks,
    List<Course>? initialCourses,
  }) => InMemoryAppData._(
    initialTasks: initialTasks,
    initialCourses: initialCourses,
  );

  Future<void> dispose() async {}
}

class _InMemoryAppDataRepository implements AppDataRepository {
  _InMemoryAppDataRepository({
    List<Task>? initialTasks,
    List<Course>? initialCourses,
  }) : _tasks = List.of(initialTasks ?? AppDataRepository.instance.tasks),
       _courses = List.of(
         initialCourses ?? AppDataRepository.instance.courses,
       );

  final List<Task> _tasks;
  final List<Course> _courses;

  @override
  List<Task> get tasks => List.unmodifiable(_tasks);

  @override
  List<Course> get courses => List.unmodifiable(_courses);

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Task>> fetchTasks() async => tasks;

  @override
  Future<Task> addTask(Task task) async {
    final id = task.id > 0
        ? task.id
        : (_tasks.isEmpty
              ? 1
              : _tasks.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
                    1);
    final savedTask = task.copyWith(id: id);
    _tasks.add(savedTask);
    return savedTask;
  }

  @override
  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) throw StateError('Tugas ${updatedTask.id} tidak ditemukan.');
    _tasks[index] = updatedTask;
  }

  @override
  Future<void> deleteTask(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw StateError('Tugas $id tidak ditemukan.');
    _tasks.removeAt(index);
  }

  @override
  Future<void> addCourse(Course course) async {
    if (_courses.any((item) => item.id == course.id)) {
      throw StateError('ID mata kuliah ${course.id} sudah digunakan.');
    }
    _courses.add(course);
  }

  @override
  Future<void> updateCourse(Course updatedCourse) async {
    final index = _courses.indexWhere(
      (course) => course.id == updatedCourse.id,
    );
    if (index == -1) {
      throw StateError('Mata kuliah ${updatedCourse.id} tidak ditemukan.');
    }

    final previousName = _courses[index].name;
    _courses[index] = updatedCourse;
    if (previousName != updatedCourse.name) {
      for (var taskIndex = 0; taskIndex < _tasks.length; taskIndex++) {
        if (_tasks[taskIndex].course == previousName) {
          _tasks[taskIndex] = _tasks[taskIndex].copyWith(
            course: updatedCourse.name,
          );
        }
      }
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    final index = _courses.indexWhere((course) => course.id == id);
    if (index == -1) throw StateError('Mata kuliah $id tidak ditemukan.');
    final courseName = _courses[index].name;
    if (_tasks.any((task) => task.course == courseName)) {
      throw StateError('Mata kuliah masih digunakan oleh tugas.');
    }
    _courses.removeAt(index);
  }
}
