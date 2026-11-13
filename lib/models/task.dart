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
    this.attachmentPath,
  });

  final int id;
  final String title;
  final String course;
  final DateTime deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final Scratchpad? scratchpad;
  final List<FocusLog> focusLogs;
  final String? attachmentPath;

  factory Task.fromJson(Map<String, dynamic> json) {
    final priorityName = json['priority'];
    final priority = TaskPriority.values.where(
      (value) => value.name == priorityName,
    );
    if (priority.isEmpty) {
      throw FormatException('Prioritas tugas tidak dikenal: $priorityName');
    }

    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      course: json['course'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: priority.first,
      isCompleted: json['isCompleted'] as bool? ?? false,
      scratchpad: json['scratchpad'] == null
          ? null
          : Scratchpad.fromJson(
              Map<String, dynamic>.from(json['scratchpad'] as Map),
            ),
      focusLogs: (json['focusLogs'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                FocusLog.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(),
      attachmentPath: json['attachmentPath'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'course': course,
    'deadline': deadline.toIso8601String(),
    'priority': priority.name,
    'isCompleted': isCompleted,
    'scratchpad': scratchpad?.toJson(),
    'focusLogs': focusLogs.map((log) => log.toJson()).toList(),
    'attachmentPath': attachmentPath,
  };

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
    String? attachmentPath,
    bool clearAttachment = false,
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
      attachmentPath: clearAttachment
          ? null
          : attachmentPath ?? this.attachmentPath,
    );
  }
}
