import 'package:falta_app/features/favorites/domain/entities/favorite_entry_entity.dart';

abstract class FavoritesRepository {
  /// `GET /favorites`.
  Future<List<FavoriteEntryEntity>> getFavorites({required String token});

  /// `POST /favorites`. Returns the created entry (with its `favoriteId`).
  Future<FavoriteEntryEntity> addFavorite({
    required String itemType,
    required String itemId,
    required String token,
  });

  /// `DELETE /favorites/{favoriteId}`.
  Future<void> removeFavorite({
    required String favoriteId,
    required String token,
  });
}
