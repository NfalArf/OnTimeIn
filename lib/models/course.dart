
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

  Course copyWith({
    String? name,
    int? semester,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      semester: semester ?? this.semester,
      userId: userId,
    );
  }
}
