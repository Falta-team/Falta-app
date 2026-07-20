import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that persists updated app settings.
class SaveSettings {
  const SaveSettings(this._repository);

  final ProfileRepository _repository;

  Future<AppSettingsEntity> call(AppSettingsEntity settings) {
    return _repository.saveSettings(settings);
  }
}
