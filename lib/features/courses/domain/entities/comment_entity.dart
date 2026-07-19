/// Entity representing a single comment on a course video.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no HTTP).
class CommentEntity {
  const CommentEntity({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.body,
    required this.likesCount,
    required this.createdAt,
  });

  final String id;
  final String videoId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String body;
  final int likesCount;
  final DateTime? createdAt;
}
