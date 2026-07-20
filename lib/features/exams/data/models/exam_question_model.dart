import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';

class ExamOptionModel extends ExamOptionEntity {
  const ExamOptionModel({
    required super.id,
    required super.text,
    super.isCorrect,
  });

  factory ExamOptionModel.fromJson(Map<String, dynamic> json) {
    return ExamOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCorrect': isCorrect,
      };
}

class ExamQuestionModel extends ExamQuestionEntity {
  const ExamQuestionModel({
    required super.id,
    required super.text,
    required super.options,
    super.selectedOptionId,
  });

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? <dynamic>[];
    return ExamQuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      selectedOptionId: json['selectedOptionId'] as String?,
      options: optionsJson
          .map((e) => ExamOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'selectedOptionId': selectedOptionId,
        'options': options
            .map(
              (o) => ExamOptionModel(
                id: o.id,
                text: o.text,
                isCorrect: o.isCorrect,
              ).toJson(),
            )
            .toList(),
      };
}
