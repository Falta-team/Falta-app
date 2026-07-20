import 'package:falta_app/features/profile/data/models/profile_model.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';

/// Local mock data source for the profile feature.
///
/// Replace the bodies with real API calls when the backend is ready —
/// the repository and UI layers won't need to change.
class ProfileLocalDataSource {
  static ProfileModel _profile = const ProfileModel(
    id: 'u1',
    fullName: 'دينا أسعد الفليت',
    branch: 'الفرع العلمي',
    countryCode: '+970',
    phone: '597-559-410',
  );

  static AppSettingsEntity _settings = const AppSettingsEntity(
    difficulty: ExamDifficulty.hard,
    notificationsEnabled: true,
    soundEnabled: true,
  );

  Future<ProfileModel> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  Future<ProfileModel> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _profile = ProfileModel(
      id: _profile.id,
      fullName: fullName,
      branch: _profile.branch,
      countryCode: countryCode,
      phone: phone,
      avatarUrl: _profile.avatarUrl,
    );
    return _profile;
  }

  Future<AppSettingsEntity> fetchSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _settings;
  }

  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _settings = settings;
    return _settings;
  }

  Future<List<FavoriteTeacherEntity>> fetchFavoriteTeachers() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<FavoriteTeacherEntity>.generate(
      6,
      (i) => FavoriteTeacherEntity(
        id: 't$i',
        name: 'الأستاذ محمد اسماعيل',
        bio: 'بكالوريس رياضيات خبره في مجال التدريس',
        price: 15,
        rating: 4,
        image: 'math',
      ),
    );
  }

  Future<List<FavoriteLessonEntity>> fetchFavoriteLessons() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<FavoriteLessonEntity>.generate(
      4,
      (i) => FavoriteLessonEntity(
        id: 'l$i',
        lessonTitle: 'الدرس الاول',
        subject: 'التفاضل والتكامل',
        teacherName: 'الأستاذ محمد اسماعيل',
        image: 'math',
      ),
    );
  }
}
