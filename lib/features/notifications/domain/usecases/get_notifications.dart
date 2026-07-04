import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case that fetches all Notifications items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetNotifications`, `AddNotifications`, ...).
class GetNotifications {
  const GetNotifications(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationsEntity>> call() {
    return _repository.getAll();
  }
}
