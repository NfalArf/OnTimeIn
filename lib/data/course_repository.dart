
import '../models/course.dart';

class CourseRepository {
  final List<Course> _courses = [
    const Course(
      id: 'course-1',
      name: 'Rekayasa Perangkat Lunak',
      semester: 5,
    ),
    const Course(
      id: 'course-2',
      name: 'Basis Data',
      semester: 5,
    ),
    const Course(
      id: 'course-3',
      name: 'Pemrograman Mobile',
      semester: 5,
    ),
    const Course(
      id: 'course-4',
      name: 'Algoritma dan Pemrograman',
      semester: 1,
    ),
    const Course(
      id: 'course-5',
      name: 'Struktur Data',
      semester: 3,
    ),
  ];

  List<Course> getCourses() {
    return List<Course>.unmodifiable(_courses);
  }

  void addCourse(Course course) {
    _courses.add(course);
  }

  void updateCourse(Course updatedCourse) {
    final index = _courses.indexWhere(
      (course) => course.id == updatedCourse.id,
    );

    if (index == -1) return;

    _courses[index] = updatedCourse;
  }

  void deleteCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
  }
}
