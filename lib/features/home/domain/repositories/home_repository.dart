import 'package:falta_app/features/home/domain/entities/home_entity.dart';

/// Abstract contract for the Home feature.
///
/// The implementation lives in the data layer
/// (`home_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class HomeRepository {
  Future<List<HomeEntity>> getAll();
}
