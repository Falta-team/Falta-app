import 'dart:io';

import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
  });

  Future<ProfileEntity> uploadProfilePhoto(File file);

  Future<void> deleteAccount({required String password});

  Future<AppSettingsEntity> getSettings();

  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings);

  Future<List<FavoriteTeacherEntity>> getFavoriteTeachers();

  Future<List<FavoriteLessonEntity>> getFavoriteLessons();
}
