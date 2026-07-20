import 'package:falta_app/features/exams/domain/entities/exam_lesson_entity.dart';

class ExamUnitEntity {
  const ExamUnitEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
    this.isExpanded = false,
    this.isSelected = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<ExamLessonEntity> lessons;
  final bool isExpanded;
  final bool isSelected;

  ExamUnitEntity copyWith({
    List<ExamLessonEntity>? lessons,
    bool? isExpanded,
    bool? isSelected,
  }) {
    return ExamUnitEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      lessons: lessons ?? this.lessons,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
