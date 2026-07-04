import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

/// Abstract contract for the Profile feature.
///
/// The implementation lives in the data layer
/// (`profile_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class ProfileRepository {
  Future<List<ProfileEntity>> getAll();
}
