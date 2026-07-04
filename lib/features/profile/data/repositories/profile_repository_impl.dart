import 'package:falta_app/features/profile/data/models/profile_model.dart';
import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Concrete implementation of [ProfileRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl();

  @override
  Future<List<ProfileEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<ProfileModel> rawData = <ProfileModel>[];
    return rawData;
  }
}
