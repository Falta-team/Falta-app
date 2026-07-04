import 'package:falta_app/features/ai/domain/entities/ai_entity.dart';

/// Data model for Ai.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [AiEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class AiModel extends AiEntity {
  const AiModel({
    required super.id,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
