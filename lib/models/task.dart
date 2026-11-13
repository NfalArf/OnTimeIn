import 'focus_log.dart';
import 'scratchpad.dart';

enum TaskPriority { high, medium, normal }

class Task {
  const Task({
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    this.id = 0,
    this.isCompleted = false,
    this.scratchpad,
    this.focusLogs = const [],
  });

  final int id;
  final String title;
  final String course;
  final DateTime deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final Scratchpad? scratchpad;
  final List<FocusLog> focusLogs;

  Task copyWith({
    int? id,
    String? title,
    String? course,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
    Scratchpad? scratchpad,
    bool clearScratchpad = false,
    List<FocusLog>? focusLogs,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      scratchpad: clearScratchpad ? null : scratchpad ?? this.scratchpad,
      focusLogs: focusLogs ?? this.focusLogs,
    );
  }
}
