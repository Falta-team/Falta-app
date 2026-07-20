import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';

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
    // ── 1. حاول تجيب user object nested ────────────────────────────────────
    final dynamic rawUser = json['user'];
    final Map<String, dynamic>? user =
    rawUser is Map<String, dynamic> ? rawUser : null;

    // ── 2. ركّب الاسم الكامل من firstName + lastName ───────────────────────
    // ── 3. اسم المستخدم — الـ API بيرجع fullName مباشرة ──────────────────
    final String userName =
    user?['fullName']?.toString().trim().isNotEmpty == true
        ? user!['fullName'].toString().trim()
        : (json['fullName']?.toString().trim().isNotEmpty == true
        ? json['fullName'].toString().trim()
        : (json['userName']?.toString().trim().isNotEmpty == true
        ? json['userName'].toString().trim()
        : 'مستخدم'));

    // ── 4. Avatar ──────────────────────────────────────────────────────────
    final String avatarUrl =
        (user?['profilePhotoUrl'] ?? json['userAvatarUrl'])?.toString() ?? '';

    return CommentModel(
      id:           json['id']?.toString()      ?? '',
      videoId:      json['videoId']?.toString() ?? '',
      userId:       (json['userId'] ?? user?['id'])?.toString() ?? '',
      userName:     userName,
      userAvatarUrl: avatarUrl,
      body:         json['body']?.toString() ?? json['comment']?.toString() ?? '',
      likesCount:   (json['likesCount'] as num?)?.toInt() ?? 0,
      createdAt:    DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}