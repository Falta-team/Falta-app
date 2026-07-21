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

  /// Parses a question the way the real API returns it inside
  /// `POST /exams/{id}/start`: `{ id, questionText, optionA..D, topicTag }`.
  ///
  /// `correctAnswer` is intentionally NOT trusted here even if present —
  /// the student shouldn't receive it before submitting — so every
  /// option starts as `isCorrect: false`. The real answer key only ever
  /// gets merged in client-side after grading (see
  /// `ExamResultModel.mergeGraded`), from the `submit` response.
  ///
  /// Falls back to the generic `{ id, text, options: [...] }` shape for
  /// safety, in case a different endpoint ever returns that instead.
  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    final hasLetterOptions = json.containsKey('optionA') ||
        json.containsKey('optionB') ||
        json.containsKey('optionC') ||
        json.containsKey('optionD');

    if (hasLetterOptions) {
      const letters = ['a', 'b', 'c', 'd'];
      const keys = ['optionA', 'optionB', 'optionC', 'optionD'];
      final options = <ExamOptionModel>[
        for (var i = 0; i < letters.length; i++)
          if (json[keys[i]] != null)
            ExamOptionModel(
              id: letters[i],
              text: json[keys[i]] as String? ?? '',
            ),
      ];
      return ExamQuestionModel(
        id: id,
        text: json['questionText'] as String? ?? json['text'] as String? ?? '',
        options: options,
      );
    }

    final optionsJson = json['options'] as List<dynamic>? ?? <dynamic>[];
    return ExamQuestionModel(
      id: id,
      text: json['text'] as String? ?? '',
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
