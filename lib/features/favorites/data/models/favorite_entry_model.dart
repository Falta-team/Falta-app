import 'package:falta_app/features/favorites/domain/entities/favorite_entry_entity.dart';

/// Parses a single favorite entry from the API.
///
/// Confirmed shape for adding one (`POST /favorites` body):
/// `{ itemType: "course", itemId: "..." }`. The exact shape `GET
/// /favorites` returns per entry isn't documented, so this handles a
/// few reasonable possibilities defensively:
/// - flat: `{ id, itemType, itemId }`
/// - populated: `{ id, itemType, itemId, course: {...} }` (or
///   `instructor`/`item`/`data` instead of `course`)
class FavoriteEntryModel extends FavoriteEntryEntity {
  const FavoriteEntryModel({
    required super.favoriteId,
    required super.itemType,
    required super.itemId,
    super.title,
    super.subtitle,
    super.image,
    super.meta,
  });

  factory FavoriteEntryModel.fromJson(Map<String, dynamic> rawJson) {
    // Some list endpoints wrap each entry as `{ favorite: {...} }`.
    final json = rawJson['favorite'] is Map<String, dynamic>
        ? rawJson['favorite'] as Map<String, dynamic>
        : rawJson;

    final itemType =
        json['itemType'] as String? ?? json['type'] as String? ?? 'course';
    final itemId = json['itemId']?.toString() ??
        json['courseId']?.toString() ??
        json['instructorId']?.toString() ??
        '';

    final nested = json['course'] ??
        json['instructor'] ??
        json['item'] ??
        json['data'];

    String title = '';
    String subtitle = '';
    String image = '';
    String meta = '';
    if (nested is Map<String, dynamic>) {
      title = nested['title'] as String? ??
          nested['fullName'] as String? ??
          nested['name'] as String? ??
          '';
      subtitle = nested['instructorName'] as String? ??
          nested['fullName'] as String? ??
          '';
      image = nested['image'] as String? ?? '';
      meta = nested['subject'] as String? ?? nested['bio'] as String? ?? '';
    }

    return FavoriteEntryModel(
      favoriteId: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['favoriteId']?.toString() ??
          json['uuid']?.toString() ??
          '',
      itemType: itemType,
      itemId: itemId,
      title: title,
      subtitle: subtitle,
      image: image,
      meta: meta,
    );
  }
}
