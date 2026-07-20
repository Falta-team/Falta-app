import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

/// Data model for Profile.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [ProfileEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.branch,
    required super.countryCode,
    required super.phone,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '+970',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'full_name': fullName,
      'branch': branch,
      'country_code': countryCode,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}
