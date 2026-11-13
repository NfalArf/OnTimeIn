class FocusLog {
  const FocusLog({required this.durationSeconds, required this.date});

  final int durationSeconds;
  final DateTime date;

  factory FocusLog.fromJson(Map<String, dynamic> json) => FocusLog(
    durationSeconds: json['durationSeconds'] as int,
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, Object?> toJson() => {
    'durationSeconds': durationSeconds,
    'date': date.toIso8601String(),
  };
}
