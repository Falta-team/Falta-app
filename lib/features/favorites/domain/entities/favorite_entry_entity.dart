/// A single favorite entry as returned by `GET /favorites`.
///
/// The API only confirms `itemType: "course"` in its docs, but the
/// shape is kept generic (`itemType`/`itemId`) so `instructor`/`video`
/// favorites — if the backend ever returns them — work without changes.
///
/// [title]/[subtitle]/[image] are best-effort display fields: populated
/// either from a nested item object the API may include in the favorite
/// entry, or filled in locally right after adding a favorite (since the
/// screen doing the adding already has the full course/instructor at
/// hand). They may be empty if neither source had the data — callers
/// should fall back to just navigating via [itemId] in that case.
class FavoriteEntryEntity {
  const FavoriteEntryEntity({
    required this.favoriteId,
    required this.itemType,
    required this.itemId,
    this.title = '',
    this.subtitle = '',
    this.image = '',
    this.meta = '',
  });

  /// The favorite record's own id — used for `DELETE /favorites/{id}`.
  final String favoriteId;

  /// e.g. `"course"`, `"instructor"`.
  final String itemType;

  /// The id of the favorited course/instructor/etc.
  final String itemId;

  final String title;
  final String subtitle;
  final String image;

  /// Extra display text (course subject, teacher bio, ...).
  final String meta;

  FavoriteEntryEntity copyWith({
    String? title,
    String? subtitle,
    String? image,
    String? meta,
  }) {
    return FavoriteEntryEntity(
      favoriteId: favoriteId,
      itemType: itemType,
      itemId: itemId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      meta: meta ?? this.meta,
    );
  }
}
