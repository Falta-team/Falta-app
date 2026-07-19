import 'package:falta_app/features/courses/domain/entities/video_entity.dart';

/// Data model for a course lesson video.
///
/// Field names below are confirmed from a real
/// `GET /courses/{id}/videos` response body:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "videos": [
///       {
///         "id": "...",
///         "courseId": "...",
///         "title": "...",
///         "description": "...",
///         "videoUrl": "https://.../video.mp4",
///         "duration": 180,
///         "sequenceOrder": 1,
///         "viewsCount": 0,
///         "createdAt": "..."
///       }
///     ]
///   }
/// }
/// ```
class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.description,
    required super.videoUrl,
    required super.duration,
    required super.sequenceOrder,
    required super.viewsCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      sequenceOrder: (json['sequenceOrder'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
    );
  }
}