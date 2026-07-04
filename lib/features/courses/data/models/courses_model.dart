import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

/// Data model for Courses.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [CoursesEntity]. This is the only layer allowed to
/// know about the raw API/DB field names.
class CoursesModel extends CoursesEntity {
  const CoursesModel({
    required super.id,
  });

  factory CoursesModel.fromJson(Map<String, dynamic> json) {
    return CoursesModel(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
