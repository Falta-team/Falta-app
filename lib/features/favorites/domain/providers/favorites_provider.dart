import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:falta_app/features/favorites/domain/entities/favorite_entry_entity.dart';
import 'package:falta_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Repository ────────────────────────────────────────────────────────────
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => const FavoritesRepositoryImpl(),
);

/// ── App-wide favorites list ─────────────────────────────────────────────
///
/// Every bookmark/heart button in the app (course detail, instructor
/// cards, the "المفضلة" screen itself, ...) watches this single provider,
/// so toggling a favorite anywhere updates every button showing that
/// item immediately.
final favoritesListProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteEntryEntity>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<FavoriteEntryEntity>> {
  /// itemType|itemId keys currently being added/removed — lets buttons
  /// show a small loading state instead of double-firing on fast taps.
  final Set<String> pending = {};

  @override
  Future<List<FavoriteEntryEntity>> build() async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) return const [];
    return ref.read(favoritesRepositoryProvider).getFavorites(token: token);
  }

  bool isFavorited(String itemType, String itemId) {
    return state.value
        ?.any((f) => f.itemType == itemType && f.itemId == itemId) ??
        false;
  }

  bool isPending(String itemType, String itemId) =>
      pending.contains('$itemType|$itemId');

  /// Adds the item if it isn't already favorited, removes it otherwise.
  /// [title]/[subtitle]/[image] are optional display data the caller
  /// already has (e.g. the course being viewed) — used so the item shows
  /// up correctly in the favorites list right away without depending on
  /// the API to echo it back populated.
  Future<void> toggle({
    required String itemType,
    required String itemId,
    String title = '',
    String subtitle = '',
    String image = '',
    String meta = '',
  }) async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      throw const FavoritesApiException('يجب تسجيل الدخول أولاً');
    }

    final key = '$itemType|$itemId';
    if (pending.contains(key)) return;
    pending.add(key);

    final repo = ref.read(favoritesRepositoryProvider);
    final current = state.value ?? const <FavoriteEntryEntity>[];
    final existing = current
        .where((f) => f.itemType == itemType && f.itemId == itemId)
        .toList();

    try {
      if (existing.isNotEmpty) {
        await repo.removeFavorite(favoriteId: existing.first.favoriteId, token: token);
        state = AsyncData([
          for (final f in current)
            if (!(f.itemType == itemType && f.itemId == itemId)) f,
        ]);
      } else {
        final created = await repo.addFavorite(
          itemType: itemType,
          itemId: itemId,
          token: token,
        );
        final entry = created.title.isEmpty && title.isNotEmpty
            ? created.copyWith(
                title: title, subtitle: subtitle, image: image, meta: meta)
            : created;
        state = AsyncData([...current, entry]);
      }
    } finally {
      pending.remove(key);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
