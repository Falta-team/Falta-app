import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/favorites/data/models/favorite_entry_model.dart';
import 'package:falta_app/features/favorites/data/sources/favorites_remote_data_source.dart';
import 'package:falta_app/features/favorites/domain/entities/favorite_entry_entity.dart';
import 'package:falta_app/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesApiException implements Exception {
  const FavoritesApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({
    this.remote = const FavoritesRemoteDataSource(),
  });

  final FavoritesRemoteDataSource remote;

  @override
  Future<List<FavoriteEntryEntity>> getFavorites({required String token}) async {
    try {
      final result = await remote.getFavorites(token: token) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];
      // ignore: avoid_print
      print('GET /favorites [$statusCode]: $body');

      if (!ApiSettings.isSuccess(statusCode)) {
        throw FavoritesApiException(
          '${_extractMessage(body) ?? 'فشل تحميل المفضلة'} ($statusCode)',
        );
      }

      final list = _extractList(body);
      final entries =
          list.map((e) => FavoriteEntryModel.fromJson(e as Map<String, dynamic>)).toList();
      // ignore: avoid_print
      print('Parsed favorites: '
          '${entries.map((e) => '{favoriteId=${e.favoriteId}, itemType=${e.itemType}, itemId=${e.itemId}}').toList()}');
      return entries;
    } on FavoritesApiException {
      rethrow;
    } catch (e) {
      throw FavoritesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<FavoriteEntryEntity> addFavorite({
    required String itemType,
    required String itemId,
    required String token,
  }) async {
    try {
      final result = await remote.addFavorite(
        itemType: itemType,
        itemId: itemId,
        token: token,
      ) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];
      // ignore: avoid_print
      print('POST /favorites [$statusCode]: $body');

      if (!ApiSettings.isSuccess(statusCode)) {
        throw FavoritesApiException(
          '${_extractMessage(body) ?? 'تعذرت إضافة العنصر للمفضلة'} ($statusCode)',
        );
      }

      final data = _extractObject(body);
      // Some APIs return just `{ id }` on create — make sure itemType/
      // itemId are still there even if the response omits them.
      final entry = FavoriteEntryModel.fromJson({
        'itemType': itemType,
        'itemId': itemId,
        ...data,
      });
      // ignore: avoid_print
      print('Parsed created favorite: favoriteId=${entry.favoriteId}');
      return entry;
    } on FavoritesApiException {
      rethrow;
    } catch (e) {
      throw FavoritesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<void> removeFavorite({
    required String favoriteId,
    required String token,
  }) async {
    if (favoriteId.isEmpty) {
      throw const FavoritesApiException(
        'تعذر تحديد العنصر لإزالته من المفضلة (favoriteId فارغ) — جرّب تحديث الصفحة',
      );
    }
    try {
      final result = await remote.removeFavorite(
        favoriteId: favoriteId,
        token: token,
      ) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];
      // ignore: avoid_print
      print('DELETE /favorites/$favoriteId [$statusCode]: $body');

      if (!ApiSettings.isSuccess(statusCode)) {
        throw FavoritesApiException(
          '${_extractMessage(body) ?? 'تعذرت إزالة العنصر من المفضلة'} ($statusCode)',
        );
      }
    } on FavoritesApiException {
      rethrow;
    } catch (e) {
      throw FavoritesApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Response-shape helpers ─────────────────────────────────────────────
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic favorites = data['favorites'];
        if (favorites is List) return favorites;
      }
      if (data is List) return data;
      final dynamic flat = body['favorites'];
      if (flat is List) return flat;
    }
    return const [];
  }

  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return const {};
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message'] as String? ?? body['error'] as String?;
    }
    return null;
  }
}
