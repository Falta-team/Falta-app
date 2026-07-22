import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:http/http.dart' as http;

class AdminApiController {
  AdminApiController({SharedPrefController? pref})
      : _pref = pref ?? SharedPrefController();

  final SharedPrefController _pref;

  Map<String, String> get _headers =>
      ApiSettings.authHeaders(_pref.accessToken);

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse(ApiSettings.adminStats),
      headers: _headers,
    );
    final data = await _decode(response, 'فشل جلب الإحصائيات');
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 50,
    String? role,
    String? search,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (role != null && role.isNotEmpty) 'role': role,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri =
        Uri.parse(ApiSettings.adminUsers).replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers);
    final data = await _decode(response, 'فشل جلب المستخدمين');
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['users'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiSettings.adminUserRole(userId)),
      headers: _headers,
      body: jsonEncode({'role': role}),
    );
    final data = await _decode(response, 'فشل تحديث الرول');
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateUserSubscription({
    required String userId,
    required String subscriptionStatus,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiSettings.adminUserSubscription(userId)),
      headers: _headers,
      body: jsonEncode({'subscriptionStatus': subscriptionStatus}),
    );
    final data = await _decode(response, 'فشل تحديث الاشتراك');
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createCards({
    required int count,
    String subscriptionType = 'standard',
    int durationDays = 30,
  }) async {
    final response = await http.post(
      Uri.parse(ApiSettings.createCards),
      headers: _headers,
      body: jsonEncode({
        'count': count,
        'subscriptionType': subscriptionType,
        'durationDays': durationDays,
      }),
    );
    final data = await _decode(response, 'فشل إنشاء البطاقات');
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<dynamic> _decode(http.Response response, String fallback) async {
    final json = jsonDecode(response.body);
    if (!ApiSettings.isSuccess(response.statusCode)) {
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        final msg = json['message'] as String? ??
            (error is Map ? error['message'] as String? : null) ??
            fallback;
        throw Exception(msg);
      }
      throw Exception(fallback);
    }
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'users': data};
      return json;
    }
    if (json is List) return {'users': json};
    return <String, dynamic>{};
  }
}
