import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that fetches the comments of a single video
/// (`GET /videos/{id}/comments`).
class GetVideoComments {
  const GetVideoComments(this._repository);

  final CoursesRepository _repository;

  Future<List<CommentEntity>> call(String videoId, String token) =>
      _repository.getVideoComments(videoId, token);
}
