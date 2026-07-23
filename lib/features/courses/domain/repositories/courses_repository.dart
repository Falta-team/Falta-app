import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/entities/course_material_entity.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';

/// Abstract contract for the Courses feature.
///
/// The implementation lives in the data layer
/// (`courses_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class CoursesRepository {
  Future<List<CoursesEntity>> getAllCourses({
    String? search,
    String? subject,
  });

  Future<CoursesEntity> getCourseDetails(String id);

  Future<List<CoursesEntity>> getCoursesBySubject(String subject);

  Future<List<CoursesEntity>> getCoursesByInstructor(String instructorId);

  Future<void> enrollCourse(String id, String token);

  /// `GET /courses/{id}/videos` — requires a Bearer token.
  Future<List<VideoEntity>> getCourseVideos(String id, String token);

  /// `GET /videos/{id}` — requires a Bearer token.
  Future<VideoEntity> getVideoById(String videoId, String token);

  /// `GET /courses/{id}/materials` — requires a Bearer token.
  Future<List<CourseMaterialEntity>> getCourseMaterials(
    String courseId,
    String token,
  );

  /// `GET /videos/{id}/comments` — requires a Bearer token.
  Future<List<CommentEntity>> getVideoComments(String videoId, String token);

  /// `POST /videos/{id}/comments` — requires a Bearer token. Returns the
  /// newly created comment.
  Future<CommentEntity> addVideoComment(
      String videoId, String token, String body);
}