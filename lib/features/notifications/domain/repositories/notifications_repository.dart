import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';

/// Abstract contract for the Notifications feature.
///
/// The implementation lives in the data layer
/// (`notifications_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class NotificationsRepository {
  Future<List<NotificationsEntity>> getAll();
}
