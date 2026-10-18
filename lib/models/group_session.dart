
class GroupSession {
  const GroupSession({
    required this.id,
    required this.title,
    required this.taskId,
    required this.taskTitle,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.location,
    required this.description,
  });

  final int id;
  final String title;
  final int taskId;
  final String taskTitle;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final String location;
  final String description;

  String get formattedTime {
    final hour = startHour.toString().padLeft(2, '0');
    final minute = startMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
