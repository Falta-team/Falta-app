import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
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



/// Use case that fetches the details of a single course
/// (`GET /courses/{id}`).
class GetCourseDetails {
  const GetCourseDetails(this._repository);

  final CoursesRepository _repository;

  Future<CoursesEntity> call(String id) => _repository.getCourseDetails(id);
}


/// Use case that enrolls the current user in a course
/// (`POST /courses/{id}/enroll`, requires a Bearer token).
class EnrollCourse {
  const EnrollCourse(this._repository);

  final CoursesRepository _repository;

  Future<void> call({required String id, required String token}) {
    return _repository.enrollCourse(id, token);
  }
}
