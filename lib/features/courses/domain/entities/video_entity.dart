/// Entity representing a single lesson video that belongs to a course.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP).
class VideoEntity {
  const VideoEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.sequenceOrder,
    required this.viewsCount,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;

  /// Direct, playable video URL (confirmed from the real API response —
  /// a plain `.mp4` link, no separate "resolve stream URL" step needed).
  final String videoUrl;

  /// Duration in seconds.
  final int duration;

  /// Order of this video within the course (1-based).
  final int sequenceOrder;

  final int viewsCount;
}