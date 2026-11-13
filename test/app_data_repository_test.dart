import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/data/app_data_repository.dart';
import 'package:nama_project/models/course.dart';
import 'package:nama_project/models/focus_log.dart';
import 'package:nama_project/models/scratchpad.dart';
import 'package:nama_project/models/task.dart';

void main() {
  late Directory directory;
  late File storageFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ontimein-data-test-');
    storageFile = File('${directory.path}${Platform.pathSeparator}data.json');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'task CRUD and nested task data survive repository recreation',
    () async {
      final task = Task(
        id: 1,
        title: 'Tugas awal',
        course: 'Basis Data',
        deadline: DateTime(2026, 12, 1, 23, 59),
        priority: TaskPriority.high,
        scratchpad: const Scratchpad(
          idea: 'Rancangan',
          strokes: [
            [Offset.zero, Offset(1, 0.5)],
          ],
        ),
        focusLogs: [
          FocusLog(durationSeconds: 300, date: DateTime(2026, 11, 14)),
        ],
        attachmentPath: 'task-photo.jpg',
      );
      final repository = AppDataRepository(
        storageFile: storageFile,
        initialTasks: [task],
        initialCourses: const [
          Course(id: 'course-1', name: 'Basis Data', semester: 5),
        ],
      );

      await repository.initialize();
      final added = await repository.addTask(
        Task(
          title: 'Tugas baru',
          course: 'Basis Data',
          deadline: DateTime(2026, 12, 10),
          priority: TaskPriority.normal,
        ),
      );
      await repository.updateTask(
        added.copyWith(isCompleted: true, attachmentPath: 'new-photo.jpg'),
      );

      final reopened = AppDataRepository(storageFile: storageFile);
      final persistedTasks = await reopened.fetchTasks();
      final persistedTask = persistedTasks.firstWhere((item) => item.id == 1);
      final persistedAdded = persistedTasks.firstWhere(
        (item) => item.id == added.id,
      );
      expect(
        persistedTask.scratchpad!.strokes.single.last,
        const Offset(1, 0.5),
      );
      expect(persistedTask.focusLogs.single.durationSeconds, 300);
      expect(persistedTask.attachmentPath, 'task-photo.jpg');
      expect(persistedAdded.isCompleted, isTrue);
      expect(persistedAdded.attachmentPath, 'new-photo.jpg');

      await reopened.deleteTask(1);
      final afterDelete = await AppDataRepository(storageFile: storageFile)
          .fetchTasks();
      expect(afterDelete.map((item) => item.id), [persistedAdded.id]);
    },
  );

  test(
    'course rename updates linked tasks and delete guards remain enforced',
    () async {
      final repository = AppDataRepository(
        storageFile: storageFile,
        initialTasks: [
          Task(
            id: 1,
            title: 'Laporan',
            course: 'Basis Data',
            deadline: DateTime(2026, 12, 1),
            priority: TaskPriority.normal,
          ),
        ],
        initialCourses: const [
          Course(id: 'db', name: 'Basis Data', semester: 5),
        ],
      );
      await repository.initialize();

      await repository.updateCourse(
        const Course(id: 'db', name: 'Sistem Basis Data', semester: 6),
      );
      expect(repository.tasks.single.course, 'Sistem Basis Data');
      await expectLater(repository.deleteCourse('db'), throwsStateError);

      await repository.deleteTask(1);
      await repository.deleteCourse('db');
      final reopened = AppDataRepository(storageFile: storageFile);
      expect(await reopened.fetchTasks(), isEmpty);
      expect(reopened.courses, isEmpty);
    },
  );
}
