import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that fetches Courses.
///
/// Pass [subject] to filter (`GET /courses/subject/{subject}`), or omit
/// it to fetch the full catalog (`GET /courses`).
class GetCourses {
  const GetCourses(this._repository);

  final CoursesRepository _repository;

  Future<List<CoursesEntity>> call({String? subject}) {
    if (subject != null && subject.isNotEmpty) {
      return _repository.getCoursesBySubject(subject);
    }
    return _repository.getAllCourses();
  }
}
