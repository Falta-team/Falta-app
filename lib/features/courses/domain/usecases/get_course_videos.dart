import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that fetches the videos of a single course
/// (`GET /courses/{id}/videos`).
class GetCourseVideos {
  const GetCourseVideos(this._repository);

  final CoursesRepository _repository;

  Future<List<VideoEntity>> call(String courseId, String token) =>
      _repository.getCourseVideos(courseId, token);
}