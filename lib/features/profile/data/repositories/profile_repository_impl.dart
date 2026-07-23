import 'dart:io';

import 'package:falta_app/features/profile/data/sources/profile_local_data_source.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({ProfileLocalDataSource? dataSource})
      : _dataSource = dataSource ?? ProfileLocalDataSource();

  final ProfileLocalDataSource _dataSource;

  @override
  Future<ProfileEntity> getProfile() => _dataSource.fetchProfile();

  @override
  Future<ProfileEntity> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
  }) {
    return _dataSource.updateProfile(
      fullName: fullName,
      countryCode: countryCode,
      phone: phone,
    );
  }

  @override
  Future<ProfileEntity> uploadProfilePhoto(File file) =>
      _dataSource.uploadProfilePhoto(file);

  @override
  Future<void> deleteAccount({required String password}) =>
      _dataSource.deleteAccount(password: password);

  @override
  Future<AppSettingsEntity> getSettings() => _dataSource.fetchSettings();

  @override
  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings) =>
      _dataSource.saveSettings(settings);

  @override
  Future<List<FavoriteTeacherEntity>> getFavoriteTeachers() =>
      _dataSource.fetchFavoriteTeachers();

  @override
  Future<List<FavoriteLessonEntity>> getFavoriteLessons() =>
      _dataSource.fetchFavoriteLessons();
}
