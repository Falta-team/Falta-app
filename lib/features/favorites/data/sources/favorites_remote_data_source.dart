import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:http/http.dart' as http;

/// Raw HTTP calls for `/favorites`. Mapping to models/entities happens
/// one layer up in [FavoritesRepositoryImpl], same split used by the
/// `courses`/`exams` features.
class FavoritesRemoteDataSource {
  const FavoritesRemoteDataSource();

  // ── GET /favorites ──────────────────────────────────────────────────────
  Future<dynamic> getFavorites({required String token}) async {
    final uri = Uri.parse(ApiSettings.favorites);
    final response = await http.get(uri, headers: ApiSettings.authHeaders(token));
    return _decode(response);
  }

  // ── POST /favorites ─────────────────────────────────────────────────────
  Future<dynamic> addFavorite({
    required String itemType,
    required String itemId,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.favorites);
    final response = await http.post(
      uri,
      headers: ApiSettings.authHeaders(token),
      body: jsonEncode({'itemType': itemType, 'itemId': itemId}),
    );
    return _decode(response);
  }

  // ── DELETE /favorites/{favoriteId} ──────────────────────────────────────
  Future<dynamic> removeFavorite({
    required String favoriteId,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.removeFavorite(favoriteId));
    final response =
        await http.delete(uri, headers: ApiSettings.authHeaders(token));
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? const {} : jsonDecode(response.body);
    } on FormatException {
      body = const {};
    }
    return {'body': body, 'statusCode': response.statusCode};
  }
}
