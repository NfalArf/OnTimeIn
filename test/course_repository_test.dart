import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/data/course_repository.dart';
import 'package:nama_project/models/course.dart';

void main() {
  test(
    'course repository adds, updates, returns immutable lists, and deletes',
    () {
      final repository = CourseRepository();
      const course = Course(id: 'test-course', name: 'Kalkulus', semester: 2);

      repository.addCourse(course);
      expect(repository.getCourses().last, course);

      final courses = repository.getCourses();
      expect(() => courses.add(course), throwsUnsupportedError);

      final updatedCourse = course.copyWith(name: 'Kalkulus Lanjut');
      repository.updateCourse(updatedCourse);
      expect(
        repository
            .getCourses()
            .singleWhere((item) => item.id == course.id)
            .name,
        'Kalkulus Lanjut',
      );

      repository.deleteCourse(course.id);
      expect(
        repository.getCourses().where((item) => item.id == course.id),
        isEmpty,
      );
    },
  );
}
