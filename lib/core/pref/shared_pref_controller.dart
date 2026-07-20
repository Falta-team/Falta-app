import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ────────────────────────────────────────────────────────────────────
enum PrefKey {
  loggedIn,
  accessToken,
  refreshToken,
  firstName,
  lastName,
  phoneNumber,
  academicBranch,
  profilePhotoUrl,
  notificationsEnabled,
}

// ── Singleton Controller ─────────────────────────────────────────────────────
class SharedPrefController {
  late SharedPreferences _prefs;

  // Singleton
  static SharedPrefController? _instance;
  SharedPrefController._();
  factory SharedPrefController() => _instance ??= SharedPrefController._();

  // استدعيها مرة وحدة في main() قبل runApp
  Future<void> initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences => _prefs;

  // ── Save after login ──────────────────────────────────────────────────────
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _prefs.setBool(PrefKey.loggedIn.name,         true);
    await _prefs.setString(PrefKey.accessToken.name,    accessToken);
    await _prefs.setString(PrefKey.refreshToken.name,   refreshToken);
    await _prefs.setString(PrefKey.firstName.name,      user['firstName']      as String? ?? '');
    await _prefs.setString(PrefKey.lastName.name,       user['lastName']       as String? ?? '');
    await _prefs.setString(PrefKey.phoneNumber.name,    user['phoneNumber']    as String? ?? '');
    await _prefs.setString(PrefKey.academicBranch.name, user['academicBranch'] as String? ?? '');
    await _prefs.setString(PrefKey.profilePhotoUrl.name,user['profilePhotoUrl']as String? ?? '');
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  bool   get isLoggedIn      => _prefs.getBool(PrefKey.loggedIn.name)         ?? false;
  String get accessToken     => _prefs.getString(PrefKey.accessToken.name)    ?? '';
  String get refreshToken    => _prefs.getString(PrefKey.refreshToken.name)   ?? '';
  String get firstName       => _prefs.getString(PrefKey.firstName.name)      ?? '';
  String get lastName        => _prefs.getString(PrefKey.lastName.name)       ?? '';
  String get fullName        => '$firstName $lastName'.trim();
  String get phoneNumber     => _prefs.getString(PrefKey.phoneNumber.name)    ?? '';
  String get academicBranch  => _prefs.getString(PrefKey.academicBranch.name) ?? '';
  String get profilePhotoUrl => _prefs.getString(PrefKey.profilePhotoUrl.name)??  '';

  // ── Notification settings toggle (defaults to on) ────────────────────────
  bool get notificationsEnabled =>
      _prefs.getBool(PrefKey.notificationsEnabled.name) ?? true;

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(PrefKey.notificationsEnabled.name, value);

  // ✅ يعيد بناء الـ user map من القيم المخزنة محلياً — مفيد لما استجابة
  // الـ refresh-token ما ترجع user (نحافظ على البيانات القديمة بدل مسحها)
  Map<String, dynamic> toUserMap() => {
    'firstName':       firstName,
    'lastName':        lastName,
    'phoneNumber':     phoneNumber,
    'academicBranch':  academicBranch,
    'profilePhotoUrl': profilePhotoUrl,
  };

  // Generic getter — نفس نمط المثال المرفق
  T? getValueFor<T>({required String key}) {
    if (_prefs.containsKey(key)) {
      return _prefs.get(key) as T?;
    }
    return null;
  }

  // ── Clear on logout ───────────────────────────────────────────────────────
  Future<bool> clear() async => _prefs.clear();
}