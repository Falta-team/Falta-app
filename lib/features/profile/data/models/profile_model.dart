import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

/// Data model for Profile.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [ProfileEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
