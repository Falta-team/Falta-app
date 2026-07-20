import 'package:falta_app/features/exams/domain/entities/exam_lesson_entity.dart';

class ExamLessonModel extends ExamLessonEntity {
  const ExamLessonModel({
    required super.id,
    required super.title,
    super.isSelected,
  });

  factory ExamLessonModel.fromJson(Map<String, dynamic> json) {
    return ExamLessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isSelected': isSelected,
      };
}
