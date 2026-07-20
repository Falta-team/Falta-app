/// Entity representing a [Profile] in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP).
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.branch,
    required this.countryCode,
    required this.phone,
    this.avatarUrl = '',
  });

  final String id;
  final String fullName;

  /// e.g. "الفرع العلمي"
  final String branch;

  /// e.g. "+970"
  final String countryCode;

  /// e.g. "597-559-410"
  final String phone;

  final String avatarUrl;

  ProfileEntity copyWith({
    String? fullName,
    String? countryCode,
    String? phone,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      branch: branch,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
