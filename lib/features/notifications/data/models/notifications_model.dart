import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';

/// Data model for Notifications (`GET /notifications`).
///
/// Field names aren't confirmed from a live response, so parsing is
/// defensive with sensible fallbacks — mirrors the pattern used in
/// `CommentModel`/`VideoModel` for the same reason.
class NotificationsModel extends NotificationsEntity {
  const NotificationsModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
