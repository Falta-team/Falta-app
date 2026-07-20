import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case that fetches all notifications for the current user
/// (`GET /notifications`).
class GetNotifications {
  const GetNotifications(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationsEntity>> call(String token) {
    return _repository.getAll(token);
  }
}
