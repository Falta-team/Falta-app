import 'package:falta_app/core/auth/app_role.dart';
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
  role,
  notificationsEnabled,
  subscriptionActive,
}

/// Official seeded team accounts (migration `013_seed_team_accounts.sql`).
/// Password for both: `Falta2026!`
const Set<String> kDemoInstructorPhones = {
  '+970599111002',
  '0599111002',
  '599111002',
  // legacy local demo (still treated as instructor UI if server role missing)
  '+970599000111',
  '0599000111',
  '599000111',
};

const Set<String> kDemoAdminPhones = {
  '+970599111001',
  '0599111001',
  '599111001',
};

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
    final phone = user['phoneNumber'] as String? ??
        _prefs.getString(PrefKey.phoneNumber.name) ??
        '';
    final roleRaw = user['role'] as String? ??
        user['userRole'] as String? ??
        user['type'] as String? ??
        '';
    var role = AppRole.fromString(roleRaw);
    if (!role.isAdmin && _isDemoPhone(phone, kDemoAdminPhones)) {
      role = AppRole.admin;
    } else if (!role.isInstructorSide &&
        _isDemoPhone(phone, kDemoInstructorPhones)) {
      role = AppRole.instructor;
    }
    await _prefs.setString(PrefKey.role.name, role.apiValue);
  }

  static bool _isDemoPhone(String phone, Set<String> candidates) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    for (final candidate in candidates) {
      final c = candidate.replaceAll(RegExp(r'\D'), '');
      if (digits == c || digits.endsWith(c) || c.endsWith(digits)) {
        return true;
      }
    }
    return false;
  }

  Future<void> setRole(AppRole role) =>
      _prefs.setString(PrefKey.role.name, role.apiValue);

  Future<void> setSubscriptionActive(bool value) =>
      _prefs.setBool(PrefKey.subscriptionActive.name, value);

  bool get subscriptionActive =>
      _prefs.getBool(PrefKey.subscriptionActive.name) ?? false;

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
  AppRole get role =>
      AppRole.fromString(_prefs.getString(PrefKey.role.name));

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
    'role':            role.apiValue,
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