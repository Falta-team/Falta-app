import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Use case that posts a new comment on a video
/// (`POST /videos/{id}/comments`).
class AddVideoComment {
  const AddVideoComment(this._repository);

  final CoursesRepository _repository;

  Future<CommentEntity> call(String videoId, String token, String body) =>
      _repository.addVideoComment(videoId, token, body);
}
