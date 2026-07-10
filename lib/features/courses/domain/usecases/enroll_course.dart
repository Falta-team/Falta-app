import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that enrolls the current user in a course
/// (`POST /courses/{id}/enroll`, requires a Bearer token).
class EnrollCourse {
  const EnrollCourse(this._repository);

  final CoursesRepository _repository;

  Future<void> call({required String id, required String token}) {
    return _repository.enrollCourse(id, token);
  }
}
