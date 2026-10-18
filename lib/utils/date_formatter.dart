
String formatTaskDeadline(DateTime deadline) {
  final day = deadline.day.toString().padLeft(2, '0');
  final month = deadline.month.toString().padLeft(2, '0');
  final year = deadline.year;
  final hour = deadline.hour.toString().padLeft(2, '0');
  final minute = deadline.minute.toString().padLeft(2, '0');

  return '$day/$month/$year, $hour:$minute';
}
