import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/focus_log.dart';
import 'package:nama_project/models/scratchpad.dart';
import 'package:nama_project/models/task.dart';
import 'package:nama_project/utils/task_management.dart';

Task _task({
  required int id,
  required DateTime deadline,
  bool isCompleted = false,
  String course = 'Basis Data',
}) {
  return Task(
    id: id,
    title: 'Task $id',
    course: course,
    deadline: deadline,
    priority: TaskPriority.normal,
    isCompleted: isCompleted,
  );
}

void main() {
  final now = DateTime(2026, 10, 31, 12);

  test(
    'priority is deterministic for completed, overdue, and upcoming tasks',
    () {
      expect(
        TaskManagement.priorityFor(
          _task(id: 1, deadline: now.subtract(const Duration(minutes: 1))),
          now: now,
        ),
        TaskPriority.high,
      );
      expect(
        TaskManagement.priorityFor(
          _task(id: 2, deadline: now.add(const Duration(hours: 24))),
          now: now,
        ),
        TaskPriority.high,
      );
      expect(
        TaskManagement.priorityFor(
          _task(id: 3, deadline: now.add(const Duration(days: 2))),
          now: now,
        ),
        TaskPriority.medium,
      );
      expect(
        TaskManagement.priorityFor(
          _task(
            id: 4,
            deadline: now.subtract(const Duration(days: 5)),
            isCompleted: true,
          ),
          now: now,
        ),
        TaskPriority.normal,
      );
    },
  );

  test('filters by course and status before sorting by deadline', () {
    final tasks = [
      _task(id: 1, deadline: now.add(const Duration(days: 2))),
      _task(
        id: 2,
        deadline: now.add(const Duration(days: 1)),
        course: 'Pemrograman Mobile',
      ),
      _task(
        id: 3,
        deadline: now.add(const Duration(hours: 3)),
        isCompleted: true,
      ),
      _task(id: 4, deadline: now.add(const Duration(hours: 5))),
    ];

    final result = TaskManagement.filterAndSort(
      tasks,
      course: 'Basis Data',
      isCompleted: false,
    );

    expect(result.map((task) => task.id), [4, 1]);
    expect(TaskManagement.filterAndSort(tasks, course: 'Tidak ada'), isEmpty);
  });

  test('copying a task edit preserves its ID and Modul 4 data', () {
    const scratchpad = Scratchpad(idea: 'Outline');
    final focusLog = FocusLog(durationSeconds: 120, date: now);
    final task = Task(
      id: 8,
      title: 'Old title',
      course: 'Basis Data',
      deadline: now,
      priority: TaskPriority.high,
      scratchpad: scratchpad,
      focusLogs: [focusLog],
      attachmentPath: 'task-photo.jpg',
    );

    final edited = task.copyWith(title: 'New title');

    expect(edited.id, task.id);
    expect(edited.title, 'New title');
    expect(edited.scratchpad, same(scratchpad));
    expect(edited.focusLogs, same(task.focusLogs));
    expect(edited.attachmentPath, task.attachmentPath);
    expect(task.copyWith(clearAttachment: true).attachmentPath, isNull);
  });
}
