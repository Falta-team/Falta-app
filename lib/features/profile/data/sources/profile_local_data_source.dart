import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/profile/data/models/profile_model.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileLocalDataSource {
  final _pref = SharedPrefController();

  static AppSettingsEntity _settings = const AppSettingsEntity(
    difficulty: ExamDifficulty.hard,
    notificationsEnabled: true,
    soundEnabled: true,
  );

  // ── GET /users/profile ───────────────────────────────────────────────────
  Future<ProfileModel> fetchProfile() async {
    final token = _pref.accessToken;
    if (token.isEmpty) return _fromPref();

    try {
      final res = await http.get(
        Uri.parse(ApiSettings.profile),
        headers: ApiSettings.authHeaders(token),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(res.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        final user = data['user'] as Map<String, dynamic>? ?? data;

        // حفّظ في SharedPref عشان الـ HomeScreen يقراهم
        await _pref.saveSession(
          accessToken:  token,
          refreshToken: _pref.refreshToken,
          user:         user,
        );
        return _parseUser(user);
      }
    } catch (_) {}
    return _fromPref();
  }

  // ── PUT /users/profile ───────────────────────────────────────────────────
  Future<ProfileModel> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
  }) async {
    final token = _pref.accessToken;
    final parts = fullName.trim().split(' ');
    final firstName = parts.first;
    final lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    try {
      final res = await http.put(
        Uri.parse(ApiSettings.profile),
        headers: ApiSettings.authHeaders(token),
        body: jsonEncode({
          'firstName': firstName,
          'lastName':  lastName,
          'phoneNumber': phone,
        }),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(res.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        final user = data['user'] as Map<String, dynamic>? ?? data;
        await _pref.saveSession(
          accessToken:  token,
          refreshToken: _pref.refreshToken,
          user:         user,
        );
        return _parseUser(user);
      }
    } catch (_) {}

    // fallback — حدّث محلياً
    return ProfileModel(
      id:          _pref.accessToken,
      fullName:    fullName,
      branch:      _academicBranchLabel(_pref.academicBranch),
      countryCode: countryCode,
      phone:       phone,
      avatarUrl:   _pref.profilePhotoUrl,
    );
  }

  // ── Settings (local) ─────────────────────────────────────────────────────
  Future<AppSettingsEntity> fetchSettings() async => _settings;

  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings) async {
    _settings = settings;
    return _settings;
  }

  // ── Favorites (local mock لحين ربط API) ──────────────────────────────────
  Future<List<FavoriteTeacherEntity>> fetchFavoriteTeachers() async =>
      List.generate(6, (i) => FavoriteTeacherEntity(
        id: 't$i', name: 'الأستاذ محمد اسماعيل',
        bio: 'بكالوريس رياضيات', price: 15, rating: 4, image: 'math',
      ));

  Future<List<FavoriteLessonEntity>> fetchFavoriteLessons() async =>
      List.generate(4, (i) => FavoriteLessonEntity(
        id: 'l$i', lessonTitle: 'الدرس الأول',
        subject: 'التفاضل والتكامل',
        teacherName: 'الأستاذ محمد اسماعيل', image: 'math',
      ));

  // ── Helpers ───────────────────────────────────────────────────────────────
  ProfileModel _fromPref() => ProfileModel(
    id:          '',
    fullName:    _pref.fullName,
    branch:      _academicBranchLabel(_pref.academicBranch),
    countryCode: '+970',
    phone:       _pref.phoneNumber,
    avatarUrl:   _pref.profilePhotoUrl,
  );

  ProfileModel _parseUser(Map<String, dynamic> u) {
    final first = u['firstName']?.toString() ?? '';
    final last  = u['lastName']?.toString()  ?? '';
    final full  = u['fullName']?.toString()  ?? '$first $last'.trim();
    return ProfileModel(
      id:          u['id']?.toString()            ?? '',
      fullName:    full,
      branch:      _academicBranchLabel(u['academicBranch']?.toString() ?? ''),
      countryCode: '+970',
      phone:       u['phoneNumber']?.toString()   ?? '',
      avatarUrl:   u['profilePhotoUrl']?.toString() ?? '',
    );
  }

  String _academicBranchLabel(String slug) {
    const map = {
      'scientific': 'الفرع العلمي',
      'literary':   'الفرع الأدبي',
    };
    return map[slug] ?? slug;
  }
}