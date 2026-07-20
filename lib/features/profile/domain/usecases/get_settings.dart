import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that fetches the stored app settings.
class GetSettings {
  const GetSettings(this._repository);

  final ProfileRepository _repository;

  Future<AppSettingsEntity> call() {
    return _repository.getSettings();
  }
}
