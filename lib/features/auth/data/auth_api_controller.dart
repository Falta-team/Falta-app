import 'dart:convert';
import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/utils/formatters/phone_formatter.dart';
import 'package:http/http.dart' as http;

// ── Response wrapper ──────────────────────────────────────────────────────────
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResult.success(this.data)
      : success = true,
        error = null;

  const ApiResult.failure(this.error)
      : success = false,
        data = null;
}

// ── Auth Models ───────────────────────────────────────────────────────────────
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken:  json['accessToken']  as String? ?? '',
    refreshToken: json['refreshToken'] as String? ?? '',
    user:         json['user']         as Map<String, dynamic>? ?? {},
  );
}

// ── Controller ────────────────────────────────────────────────────────────────
class AuthApiController {
  // ── 1. Register ─────────────────────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String academicBranch,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.register);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({
          // Postman collection uses local `05xxxxxxxx` for register.
          'phoneNumber': PhoneFormatter.toLocalFormat(phoneNumber),
          'firstName': firstName,
          'lastName': lastName.isEmpty ? firstName : lastName,
          'password': password,
          'academicBranch': academicBranch,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        return ApiResult.success(body);
      } else {
        return ApiResult.failure(
          _extractErrorMessage(body) ?? 'فشل إنشاء الحساب',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 2. Login ─────────────────────────────────────────────────────────────────
  Future<ApiResult<AuthTokens>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.login);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password':    password,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return ApiResult.success(AuthTokens.fromJson(data));
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'رقم الجوال أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 3. Get Profile ───────────────────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> getProfile({
    required String accessToken,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.profile);
      final response = await http.get(
        uri,
        headers: ApiSettings.authHeaders(accessToken),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return ApiResult.success(data);
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'فشل تحميل بيانات المستخدم');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 4. Forgot Password ───────────────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> forgotPassword({
    required String phoneNumber,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.forgotPassword);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        return ApiResult.success(body);
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'رقم الجوال غير مسجل');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 5. Verify OTP ────────────────────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.verifyPhone);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code':        code,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        return ApiResult.success(body);
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'الرمز غير صحيح أو منتهي الصلاحية');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 6. Reset Password ────────────────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.resetPassword);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code':        code,
          'newPassword': newPassword,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        return ApiResult.success(body);
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'فشل إعادة تعيين كلمة المرور');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 7. Refresh Token ─────────────────────────────────────────────────────────
  Future<ApiResult<AuthTokens>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.refreshToken);
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (ApiSettings.isSuccess(response.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return ApiResult.success(AuthTokens.fromJson(data));
      } else {
        return ApiResult.failure(body['message'] as String? ?? 'انتهت صلاحية الجلسة');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 8. Logout ────────────────────────────────────────────────────────────────
  Future<ApiResult<void>> logout({
    required String refreshToken,
    required String accessToken,
  }) async {
    try {
      final uri = Uri.parse(ApiSettings.logout);
      final response = await http.post(
        uri,
        headers: ApiSettings.authHeaders(accessToken),
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (ApiSettings.isSuccess(response.statusCode)) {
        return const ApiResult.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.failure(body['message'] as String? ?? 'فشل تسجيل الخروج');
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  /// Prefer API `message`, then nested `error`, then validation `errors` map.
  String? _extractErrorMessage(Map<String, dynamic> body) {
    final message = body['message']?.toString();
    if (message != null && message.trim().isNotEmpty) return message;

    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) return error;
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }

    final errors = body['errors'];
    if (errors is Map) {
      final parts = <String>[];
      for (final value in errors.values) {
        if (value is List) {
          parts.addAll(value.map((e) => e.toString()));
        } else if (value != null) {
          parts.add(value.toString());
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return null;
  }
}