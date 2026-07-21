import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';

/// Data model for a single exam in the `GET /exams` catalog.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [ExamsEntity]. This is the only layer allowed to know about the raw
/// API field names.
class ExamsModel extends ExamsEntity {
  const ExamsModel({
    required super.id,
    required super.title,
    required super.subject,
    required super.year,
    required super.academicTrack,
    required super.totalQuestions,
    required super.timeLimit,
    required super.difficultyLevel,
  });

  factory ExamsModel.fromJson(Map<String, dynamic> json) {
    return ExamsModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      year: json['year']?.toString() ?? '',
      academicTrack: json['academicTrack'] as String? ?? '',
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 0,
      difficultyLevel: json['difficultyLevel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subject': subject,
      'year': year,
      'academicTrack': academicTrack,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'difficultyLevel': difficultyLevel,
    };
  }
}
