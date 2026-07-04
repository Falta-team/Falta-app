import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that fetches all Courses items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetCourses`, `AddCourses`, ...).
class GetCourses {
  const GetCourses(this._repository);

  final CoursesRepository _repository;

  Future<List<CoursesEntity>> call() {
    return _repository.getAll();
  }
}
