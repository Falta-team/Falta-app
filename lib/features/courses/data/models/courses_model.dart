import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

/// Data model for Courses.
///
/// Handles JSON (de)serialization and maps to/from the domain
/// [CoursesEntity]. This is the only layer allowed to know about the raw
/// API field names. The API may nest instructor data as
/// `instructor: {id, name}` or return it flat as
/// `instructorId` / `instructorName`, so both shapes are handled here.
class CoursesModel extends CoursesEntity {
  const CoursesModel({
    required super.id,
    required super.title,
    required super.description,
    required super.image,
    required super.subject,
    required super.instructorId,
    required super.instructorName,
    required super.academicTrack,
    required super.difficultyLevel,
    required super.lessonsCount,
    required super.rating,
    required super.totalDuration,
    required super.price,
    required super.isPaid, required super.videoCount,
  });

  factory CoursesModel.fromJson(Map<String, dynamic> json) {
    String instructorId = '';
    String instructorName = '';

    final dynamic instructorRaw = json['instructor'];
    if (instructorRaw is Map<String, dynamic>) {
      instructorId = instructorRaw['id']?.toString() ??
          instructorRaw['_id']?.toString() ??
          '';
      instructorName = instructorRaw['fullName']?.toString() ?? '';
    } else {
      instructorId = json['instructorId']?.toString() ?? '';
      instructorName = json['fullName']?.toString() ?? '';
    }

    final num? priceRaw = json['price'] as num?;

    return CoursesModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      instructorId: instructorId,
      instructorName: instructorName,
      academicTrack: json['academicTrack'] as String? ?? '',
      difficultyLevel: json['difficultyLevel'] as String? ?? '',
      lessonsCount: (json['lessonsCount'] as num?)?.toInt() ?? 0,
      videoCount: (json['videoCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ??0,
      totalDuration: (json['totalDuration'] as num?)?.toInt() ??0,
      price: priceRaw?.toDouble() ?? 70.0,
      isPaid: json['isPaid'] as bool? ?? ((priceRaw ?? 0) > 0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'subject': subject,
      'instructorId': instructorId,
      'fullName': instructorName,
      'academicTrack': academicTrack,
      'difficultyLevel': difficultyLevel,
      'lessonsCount': lessonsCount,
      'videoCount': videoCount,
      'rating': rating,
      'totalDuration': totalDuration,
      'price': price,
      'isPaid': isPaid,
    };
  }
}
