import 'dart:convert';
import 'package:falta_app/core/api/api_settings.dart';
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
    accessToken:  json['accessToken']  as String,
    refreshToken: json['refreshToken'] as String,
    user:         json['user']         as Map<String, dynamic>,
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
    required String academicBranch, // "scientific" | "literary"
  }) async {
    try {
      // Step 3: Convert String URI → Uri object
      final uri = Uri.parse(ApiSettings.register);

      // Step 4: Define request
      final response = await http.post(
        uri,
        headers: ApiSettings.jsonHeaders,
        body: jsonEncode({
          'phoneNumber':    phoneNumber,
          'firstName':      firstName,
          'lastName':       lastName,
          'password':       password,
          'academicBranch': academicBranch,
        }),
      );

      // Step 6 & 7: Check status + decode
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (ApiSettings.isSuccess(response.statusCode)) {
        return ApiResult.success(body);
      } else {
        return ApiResult.failure(
          body['message'] as String? ?? 'فشل إنشاء الحساب',
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
        return ApiResult.failure(
          body['message'] as String? ?? 'رقم الجوال أو كلمة المرور غير صحيحة',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 3. Forgot Password (Send OTP) ────────────────────────────────────────────
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
        return ApiResult.failure(
          body['message'] as String? ?? 'رقم الجوال غير مسجل',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 4. Verify OTP ────────────────────────────────────────────────────────────
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
        return ApiResult.failure(
          body['message'] as String? ?? 'الرمز غير صحيح أو منتهي الصلاحية',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 5. Reset Password ────────────────────────────────────────────────────────
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
        return ApiResult.failure(
          body['message'] as String? ?? 'فشل إعادة تعيين كلمة المرور',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }

  // ── 6. Refresh Token ─────────────────────────────────────────────────────────
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
        // ✅ نفس نمط login: اقرأ data wrapper إذا موجود
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return ApiResult.success(AuthTokens.fromJson(data));
      } else {
        return ApiResult.failure(
          body['message'] as String? ?? 'انتهت صلاحية الجلسة',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }
  // ── 7. Logout ────────────────────────────────────────────────────────────────
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
        return ApiResult.failure(
          body['message'] as String? ?? 'فشل تسجيل الخروج',
        );
      }
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال: $e');
    }
  }
}