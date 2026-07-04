import 'package:falta_app/features/notifications/data/models/notifications_model.dart';
import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Concrete implementation of [NotificationsRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl();

  @override
  Future<List<NotificationsEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<NotificationsModel> rawData = <NotificationsModel>[];
    return rawData;
  }
}
