import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that fetches the details of a single course
/// (`GET /courses/{id}`).
class GetCourseDetails {
  const GetCourseDetails(this._repository);

  final CoursesRepository _repository;

  Future<CoursesEntity> call(String id) => _repository.getCourseDetails(id);
}
