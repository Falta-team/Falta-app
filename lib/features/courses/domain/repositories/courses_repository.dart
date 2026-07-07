import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

/// Abstract contract for the Courses feature.
///
/// The implementation lives in the data layer
/// (`courses_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class CoursesRepository {
  Future<List<CoursesEntity>> getAllCourses();

  Future<CoursesEntity> getCourseDetails(String id);

  Future<List<CoursesEntity>> getCoursesBySubject(String subject);

  Future<void> enrollCourse(String id, String token);
}
