import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';

/// Data model for a video comment (`GET`/`POST /videos/{id}/comments`).
///
/// The exact response shape isn't confirmed from a live call (unlike
/// [VideoModel]/[CoursesModel]), so parsing here is defensive: it accepts
/// either a flat `userName`/`userId` pair or a nested `user: {...}` object,
/// and falls back to sensible defaults instead of throwing on missing
/// fields.
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.videoId,
    required super.userId,
    required super.userName,
    required super.userAvatarUrl,
    required super.body,
    required super.likesCount,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json['user'];
    final Map<String, dynamic>? user =
    rawUser is Map<String, dynamic> ? rawUser : null;

    final String composedName = user != null
        ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
        : '';

    return CommentModel(
      id: json['id']?.toString() ?? '',
      videoId: json['videoId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? user?['id']?.toString() ?? '',
      userName: composedName.isNotEmpty
          ? composedName
          : (json['userName']?.toString() ?? 'مستخدم'),
      userAvatarUrl:
      (user?['profilePhotoUrl'] ?? json['userAvatarUrl'])?.toString() ??
          '',
      body: json['body']?.toString() ?? json['comment']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
