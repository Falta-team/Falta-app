import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

/// Abstract contract for the Profile feature.
///
/// The implementation lives in the data layer
/// (`profile_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
  });

  Future<AppSettingsEntity> getSettings();

  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings);

  Future<List<FavoriteTeacherEntity>> getFavoriteTeachers();

  Future<List<FavoriteLessonEntity>> getFavoriteLessons();
}
