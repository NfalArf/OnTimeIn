import '../models/course.dart';
import 'app_data_repository.dart';

class CourseRepository {
  CourseRepository({AppDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? AppDataRepository.instance;

  final AppDataRepository _dataRepository;

  Future<void> initialize() => _dataRepository.initialize();

  List<Course> getCourses() => _dataRepository.courses;

  Future<void> addCourse(Course course) => _dataRepository.addCourse(course);

  Future<void> updateCourse(Course updatedCourse) =>
      _dataRepository.updateCourse(updatedCourse);

  Future<void> deleteCourse(String id) => _dataRepository.deleteCourse(id);
}
