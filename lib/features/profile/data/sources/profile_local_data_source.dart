import 'dart:convert';
import 'dart:io';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/profile/data/models/profile_model.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProfileApiException implements Exception {
  const ProfileApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProfileLocalDataSource {
  final _pref = SharedPrefController();

  static AppSettingsEntity _settings = const AppSettingsEntity(
    difficulty: ExamDifficulty.hard,
    notificationsEnabled: true,
    soundEnabled: true,
  );

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

        await _pref.saveSession(
          accessToken: token,
          refreshToken: _pref.refreshToken,
          user: user,
        );

        final prefs = user['notificationPreferences'];
        if (prefs is Map) {
          final enabled = prefs['examReminders'] == true ||
              prefs['newContent'] == true;
          await _pref.setNotificationsEnabled(enabled);
          _settings = _settings.copyWith(notificationsEnabled: enabled);
        }
        return _parseUser(user);
      }
    } catch (_) {}
    return _fromPref();
  }

  Future<ProfileModel> updateProfile({
    required String fullName,
    required String countryCode,
    required String phone,
    Map<String, bool>? notificationPreferences,
    String? profilePhotoUrl,
  }) async {
    final token = _pref.accessToken;
    final parts = fullName.trim().split(' ');
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    try {
      final payload = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        if (phone.trim().isNotEmpty) 'phoneNumber': phone.trim(),
        if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
          'profilePhotoUrl': profilePhotoUrl,
        if (notificationPreferences != null)
          'notificationPreferences': notificationPreferences,
      };

      final res = await http.put(
        Uri.parse(ApiSettings.profile),
        headers: ApiSettings.authHeaders(token),
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(res.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        final user = data['user'] as Map<String, dynamic>? ?? data;
        await _pref.saveSession(
          accessToken: token,
          refreshToken: _pref.refreshToken,
          user: user,
        );
        return _parseUser(user);
      }
      throw ProfileApiException(_extractMessage(body) ?? 'فشل تحديث الملف');
    } on ProfileApiException {
      rethrow;
    } catch (e) {
      throw ProfileApiException('خطأ في الاتصال: $e');
    }
  }

  Future<ProfileModel> uploadProfilePhoto(File file) async {
    final token = _pref.accessToken;
    if (token.isEmpty) {
      throw const ProfileApiException('يجب تسجيل الدخول أولاً');
    }

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(ApiSettings.profilePhoto),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    final filename = file.path.split(Platform.pathSeparator).last;
    final ext = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : 'jpg';
    final mime = switch (ext) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'gif' => MediaType('image', 'gif'),
      _ => MediaType('image', 'jpeg'),
    };

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        file.path,
        filename: filename,
        contentType: mime,
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (!ApiSettings.isSuccess(res.statusCode)) {
      final msg = _extractMessage(body) ?? '';
      if (res.statusCode == 503 ||
          msg.toLowerCase().contains('cloudinary') ||
          msg.contains('CLOUDINARY')) {
        throw const ProfileApiException(
          'رفع الصورة غير متاح حاليًا — إعدادات التخزين على السيرفر ناقصة. تواصل مع مطور الباك لإضافة CLOUDINARY_* في .env',
        );
      }
      throw ProfileApiException(
          msg.isNotEmpty ? msg : 'فشل رفع صورة الملف الشخصي');
    }

    final data = body['data'] as Map<String, dynamic>? ?? body;
    final user = data['user'] as Map<String, dynamic>? ?? data;
    final url = user['profilePhotoUrl']?.toString() ?? '';
    if (url.isNotEmpty) {
      await _pref.setProfilePhotoUrl(url);
    }
    await _pref.saveSession(
      accessToken: token,
      refreshToken: _pref.refreshToken,
      user: {..._pref.toUserMap(), ...user},
    );
    return _parseUser({..._pref.toUserMap(), ...user});
  }

  Future<void> deleteAccount({required String password}) async {
    final token = _pref.accessToken;
    if (token.isEmpty) {
      throw const ProfileApiException('يجب تسجيل الدخول أولاً');
    }
    final res = await http.delete(
      Uri.parse(ApiSettings.deleteAccount),
      headers: ApiSettings.authHeaders(token),
      body: jsonEncode({'password': password}),
    );
    final body = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(res.statusCode)) {
      throw ProfileApiException(_extractMessage(body) ?? 'فشل حذف الحساب');
    }
  }

  Future<AppSettingsEntity> fetchSettings() async {
    return _settings.copyWith(
      notificationsEnabled: _pref.notificationsEnabled,
    );
  }

  Future<AppSettingsEntity> saveSettings(AppSettingsEntity settings) async {
    _settings = settings;
    await _pref.setNotificationsEnabled(settings.notificationsEnabled);

    final token = _pref.accessToken;
    if (token.isNotEmpty) {
      try {
        await updateProfile(
          fullName: _pref.fullName,
          countryCode: '+970',
          phone: _pref.phoneNumber,
          notificationPreferences: {
            'examReminders': settings.notificationsEnabled,
            'newContent': settings.notificationsEnabled,
            'achievements': settings.notificationsEnabled,
          },
        );
      } catch (_) {}
    }
    return _settings;
  }

  Future<List<FavoriteTeacherEntity>> fetchFavoriteTeachers() async =>
      List.generate(
        6,
        (i) => FavoriteTeacherEntity(
          id: 't$i',
          name: 'الأستاذ محمد اسماعيل',
          bio: 'بكالوريس رياضيات',
          price: 15,
          rating: 4,
          image: 'math',
        ),
      );

  Future<List<FavoriteLessonEntity>> fetchFavoriteLessons() async =>
      List.generate(
        4,
        (i) => FavoriteLessonEntity(
          id: 'l$i',
          lessonTitle: 'الدرس الأول',
          subject: 'التفاضل والتكامل',
          teacherName: 'الأستاذ محمد اسماعيل',
          image: 'math',
        ),
      );

  ProfileModel _fromPref() => ProfileModel(
        id: '',
        fullName: _pref.fullName,
        branch: _academicBranchLabel(_pref.academicBranch),
        countryCode: '+970',
        phone: _pref.phoneNumber,
        avatarUrl: _pref.profilePhotoUrl,
      );

  ProfileModel _parseUser(Map<String, dynamic> u) {
    final first = u['firstName']?.toString() ?? '';
    final last = u['lastName']?.toString() ?? '';
    final full = u['fullName']?.toString() ?? '$first $last'.trim();
    return ProfileModel(
      id: u['id']?.toString() ?? '',
      fullName: full,
      branch: _academicBranchLabel(u['academicBranch']?.toString() ?? ''),
      countryCode: '+970',
      phone: u['phoneNumber']?.toString() ?? '',
      avatarUrl: u['profilePhotoUrl']?.toString() ?? '',
    );
  }

  String _academicBranchLabel(String slug) {
    const map = {
      'scientific': 'الفرع العلمي',
      'literary': 'الفرع الأدبي',
    };
    return map[slug] ?? slug;
  }

  String? _extractMessage(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    return body['message'] as String?;
  }
}
