import 'package:falta_app/features/home/domain/entities/home_entity.dart';

/// Data model for Home.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [HomeEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
