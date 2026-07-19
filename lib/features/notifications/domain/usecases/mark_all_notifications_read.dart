import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case that marks every notification as read
/// (`PUT /notifications/read-all`).
class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String token) {
    return _repository.markAllRead(token);
  }
}
