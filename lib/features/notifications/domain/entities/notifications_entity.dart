/// Entity representing a single notification in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP).
class NotificationsEntity {
  const NotificationsEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;

  /// e.g. `new_lesson`, `reply`, `exam`, `system` — used to pick an icon
  /// and, for local push notifications, a notification channel.
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  NotificationsEntity copyWith({bool? isRead}) => NotificationsEntity(
    id: id,
    title: title,
    body: body,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
