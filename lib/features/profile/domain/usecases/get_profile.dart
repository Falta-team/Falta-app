import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that fetches the current user's profile.
class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call() {
    return _repository.getProfile();
  }
}
