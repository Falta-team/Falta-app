import 'package:falta_app/features/courses/domain/entities/course_material_entity.dart';

class CourseMaterialModel extends CourseMaterialEntity {
  const CourseMaterialModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.fileUrl,
    required super.materialType,
    super.description,
    super.sequenceOrder,
  });

  factory CourseMaterialModel.fromJson(Map<String, dynamic> json) {
    return CourseMaterialModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? json['url']?.toString() ?? '',
      materialType:
          json['materialType']?.toString() ?? json['type']?.toString() ?? 'pdf',
      sequenceOrder: (json['sequenceOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
