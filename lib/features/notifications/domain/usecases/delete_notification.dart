import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case that deletes a single notification
/// (`DELETE /notifications/{id}`).
class DeleteNotification {
  const DeleteNotification(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String id, String token) {
    return _repository.delete(id, token);
  }
}
