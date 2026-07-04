import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Data model for {{feature_name.pascalCase()}}.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [{{feature_name.pascalCase()}}Entity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class {{feature_name.pascalCase()}}Model extends {{feature_name.pascalCase()}}Entity {
  const {{feature_name.pascalCase()}}Model({
    required super.id,
  });

  factory {{feature_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) {
    return {{feature_name.pascalCase()}}Model(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
