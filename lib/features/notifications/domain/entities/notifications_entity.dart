/// Entity representing a [Notifications] in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP). Add the fields relevant to this
/// feature below.
class NotificationsEntity {
  const NotificationsEntity({
    required this.id,
  });

  final String id;
}
