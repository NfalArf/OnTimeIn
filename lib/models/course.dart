class Course {
  const Course({
    required this.id,
    required this.name,
    required this.semester,
    this.userId,
  });

  final String id;
  final String name;
  final int semester;
  final String? userId;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    name: json['name'] as String,
    semester: json['semester'] as int,
    userId: json['userId'] as String?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'semester': semester,
    'userId': userId,
  };

  Course copyWith({String? name, int? semester}) {
    return Course(
      id: id,
      name: name ?? this.name,
      semester: semester ?? this.semester,
      userId: userId,
    );
  }
}
