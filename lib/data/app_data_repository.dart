import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/course.dart';
import '../models/task.dart';
import 'app_data_store.dart';

class AppDataRepository {
  AppDataRepository({
    File? storageFile,
    List<Task>? initialTasks,
    List<Course>? initialCourses,
  }) : _storageFileOverride = storageFile,
       _tasks = List.of(initialTasks ?? _seedTasks()),
       _courses = List.of(initialCourses ?? _seedCourses());

  static final AppDataRepository instance = AppDataRepository._();

  AppDataRepository._()
    : _storageFileOverride = null,
      _tasks = _seedTasks(),
      _courses = List.of(_seedCourses());

  static const _schemaVersion = 1;
  final File? _storageFileOverride;
  final List<Task> _tasks;
  final List<Course> _courses;
  Future<void>? _initializing;
  Future<void> _writeTail = Future<void>.value();
  bool _initialized = false;

  List<Task> get tasks => List<Task>.unmodifiable(_tasks);
  List<Course> get courses => List<Course>.unmodifiable(_courses);

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??= _load()
        .then((_) {
          _initialized = true;
        })
        .catchError((Object error, StackTrace stackTrace) {
          _initializing = null;
          Error.throwWithStackTrace(error, stackTrace);
        });
  }

  Future<List<Task>> fetchTasks() async {
    await initialize();
    return tasks;
  }

  Future<Task> addTask(Task task) async {
    await initialize();
    if (task.id > 0 && _tasks.any((item) => item.id == task.id)) {
      throw StateError('ID tugas ${task.id} sudah digunakan.');
    }
    final nextId = _tasks.isEmpty
        ? 1
        : _tasks.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
    final savedTask = task.copyWith(id: task.id > 0 ? task.id : nextId);
    await _commit(() => _tasks.add(savedTask));
    return savedTask;
  }

  Future<void> updateTask(Task updatedTask) async {
    await initialize();
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) {
      throw StateError('Tugas ${updatedTask.id} tidak ditemukan.');
    }
    await _commit(() => _tasks[index] = updatedTask);
  }

  Future<void> deleteTask(int id) async {
    await initialize();
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw StateError('Tugas $id tidak ditemukan.');
    await _commit(() => _tasks.removeAt(index));
  }

  Future<void> addCourse(Course course) async {
    await initialize();
    if (_courses.any((item) => item.id == course.id)) {
      throw StateError('ID mata kuliah ${course.id} sudah digunakan.');
    }
    await _commit(() => _courses.add(course));
  }

  Future<void> updateCourse(Course updatedCourse) async {
    await initialize();
    final index = _courses.indexWhere(
      (course) => course.id == updatedCourse.id,
    );
    if (index == -1) {
      throw StateError('Mata kuliah ${updatedCourse.id} tidak ditemukan.');
    }

    await _commit(() {
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
    });
  }

  Future<void> deleteCourse(String id) async {
    await initialize();
    final index = _courses.indexWhere((course) => course.id == id);
    if (index == -1) throw StateError('Mata kuliah $id tidak ditemukan.');

    final courseName = _courses[index].name;
    if (_tasks.any((task) => task.course == courseName)) {
      throw StateError('Mata kuliah masih digunakan oleh tugas.');
    }
    await _commit(() => _courses.removeAt(index));
  }

  Future<void> _commit(void Function() mutation) async {
    final oldTasks = List<Task>.of(_tasks);
    final oldCourses = List<Course>.of(_courses);
    mutation();
    try {
      await _persist();
    } on Object {
      _tasks
        ..clear()
        ..addAll(oldTasks);
      _courses
        ..clear()
        ..addAll(oldCourses);
      rethrow;
    }
  }

  Future<void> _load() async {
    final storedData = await readStoredData(_storageFileOverride?.path);
    if (storedData == null) {
      await _persist();
      return;
    }

    final decoded = jsonDecode(storedData);
    if (decoded is! Map<String, dynamic> ||
        decoded['schemaVersion'] != _schemaVersion ||
        decoded['tasks'] is! List<dynamic> ||
        decoded['courses'] is! List<dynamic>) {
      throw const FormatException('Format penyimpanan OnTimeIn tidak valid.');
    }

    final tasks = (decoded['tasks'] as List<dynamic>)
        .map((value) => Task.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList();
    final courses = (decoded['courses'] as List<dynamic>)
        .map(
          (value) => Course.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList();
    _tasks
      ..clear()
      ..addAll(tasks);
    _courses
      ..clear()
      ..addAll(courses);
  }

  Future<void> _persist() async {
    final snapshot = jsonEncode({
      'schemaVersion': _schemaVersion,
      'tasks': _tasks.map((task) => task.toJson()).toList(),
      'courses': _courses.map((course) => course.toJson()).toList(),
    });
    final completer = Completer<void>();
    final previousWrite = _writeTail;
    _writeTail = completer.future;

    unawaited(() async {
      try {
        await previousWrite.catchError((Object _) {});
        await writeStoredData(snapshot, _storageFileOverride?.path);
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }());

    return completer.future;
  }

  static List<Task> _seedTasks() {
    final today = DateTime.now();
    DateTime deadlineIn(int days, int hour) =>
        DateTime(today.year, today.month, today.day + days, hour, 59);

    return [
      Task(
        id: 1,
        title: 'Mobile Programming Assignment',
        course: 'Pemrograman Mobile',
        deadline: deadlineIn(3, 23),
        priority: TaskPriority.high,
      ),
      Task(
        id: 2,
        title: 'Database Report',
        course: 'Basis Data',
        deadline: deadlineIn(7, 23),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 3,
        title: 'Read Chapter 4 and make notes',
        course: 'Human Computer Interaction',
        deadline: deadlineIn(10, 10),
        priority: TaskPriority.normal,
      ),
      Task(
        id: 4,
        title: 'Group presentation outline',
        course: 'Software Engineering',
        deadline: deadlineIn(14, 16),
        priority: TaskPriority.normal,
        isCompleted: true,
      ),
    ];
  }

  static List<Course> _seedCourses() => const [
    Course(id: 'course-1', name: 'Rekayasa Perangkat Lunak', semester: 5),
    Course(id: 'course-2', name: 'Basis Data', semester: 5),
    Course(id: 'course-3', name: 'Pemrograman Mobile', semester: 5),
    Course(id: 'course-4', name: 'Algoritma dan Pemrograman', semester: 1),
    Course(id: 'course-5', name: 'Struktur Data', semester: 3),
    Course(id: 'course-6', name: 'Human Computer Interaction', semester: 5),
    Course(id: 'course-7', name: 'Software Engineering', semester: 5),
  ];
}
