import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Fetches courses. With [search] uses `GET /courses?search=&subject=`.
/// With only [subject] uses `GET /courses/subject/{subject}`.
class GetCourses {
  const GetCourses(this._repository);

  final CoursesRepository _repository;

  Future<List<CoursesEntity>> call({String? subject, String? search}) {
    if (search != null && search.trim().isNotEmpty) {
      return _repository.getAllCourses(search: search, subject: subject);
    }
    if (subject != null && subject.isNotEmpty) {
      return _repository.getCoursesBySubject(subject);
    }
    return _repository.getAllCourses();
  }
}
