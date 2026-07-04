import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';

/// Data model for Exams.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [ExamsEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class ExamsModel extends ExamsEntity {
  const ExamsModel({
    required super.id,
  });

  factory ExamsModel.fromJson(Map<String, dynamic> json) {
    return ExamsModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
