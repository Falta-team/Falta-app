import 'package:falta_app/features/exams/data/models/exam_lesson_model.dart';
import 'package:falta_app/features/exams/domain/entities/exam_unit_entity.dart';

class ExamUnitModel extends ExamUnitEntity {
  const ExamUnitModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.lessons,
    super.isExpanded,
    super.isSelected,
  });

  factory ExamUnitModel.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List<dynamic>? ?? <dynamic>[];
    return ExamUnitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      isExpanded: json['isExpanded'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
      lessons: lessonsJson
          .map((e) => ExamLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isExpanded': isExpanded,
        'isSelected': isSelected,
        'lessons': lessons
            .map(
              (l) => ExamLessonModel(
                id: l.id,
                title: l.title,
                isSelected: l.isSelected,
              ).toJson(),
            )
            .toList(),
      };
}
