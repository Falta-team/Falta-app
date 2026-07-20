import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that saves the edited profile fields.
class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String fullName,
    required String countryCode,
    required String phone,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      countryCode: countryCode,
      phone: phone,
    );
  }
}
