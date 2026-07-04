import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';

/// Data model for Notifications.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [NotificationsEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class NotificationsModel extends NotificationsEntity {
  const NotificationsModel({
    required super.id,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
