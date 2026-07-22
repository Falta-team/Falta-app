import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:http/http.dart' as http;

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.active,
    this.expiresAt,
    this.type,
    this.message,
  });

  final bool active;
  final String? expiresAt;
  final String? type;
  final String? message;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final status = (data['status'] ?? data['subscriptionStatus'] ?? '')
        .toString()
        .toLowerCase();
    final active = data['active'] == true ||
        data['isActive'] == true ||
        status == 'active';
    return SubscriptionStatus(
      active: active,
      expiresAt: data['expiresAt']?.toString() ?? data['expirationDate']?.toString(),
      type: data['subscriptionType']?.toString() ?? data['type']?.toString(),
      message: data['message']?.toString(),
    );
  }
}

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource({SharedPrefController? pref})
      : _pref = pref ?? SharedPrefController();

  final SharedPrefController _pref;

  Future<SubscriptionStatus> getStatus() async {
    final response = await http.get(
      Uri.parse(ApiSettings.subscriptionStatus),
      headers: ApiSettings.authHeaders(_pref.accessToken),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل جلب حالة الاشتراك');
    }
    return SubscriptionStatus.fromJson(json);
  }

  Future<SubscriptionStatus> activateCard(String cardCode) async {
    final response = await http.post(
      Uri.parse(ApiSettings.activateCard),
      headers: ApiSettings.authHeaders(_pref.accessToken),
      body: jsonEncode({'cardCode': cardCode.trim()}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل تفعيل البطاقة');
    }
    return SubscriptionStatus.fromJson(json);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await http.get(
      Uri.parse(ApiSettings.subscriptionHistory),
      headers: ApiSettings.authHeaders(_pref.accessToken),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل جلب سجل الاشتراكات');
    }
    final data = json['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final list = data['history'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }
}
