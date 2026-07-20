class ExamOptionEntity {
  const ExamOptionEntity({
    required this.id,
    required this.text,
    this.isCorrect = false,
  });

  final String id;
  final String text;
  final bool isCorrect;
}

class ExamQuestionEntity {
  const ExamQuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    this.selectedOptionId,
  });

  final String id;
  final String text;
  final List<ExamOptionEntity> options;
  final String? selectedOptionId;

  ExamQuestionEntity copyWith({String? selectedOptionId}) {
    return ExamQuestionEntity(
      id: id,
      text: text,
      options: options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }

  bool get isAnswered => selectedOptionId != null;

  bool get isCorrect {
    if (selectedOptionId == null) return false;
    return options.any(
      (o) => o.id == selectedOptionId && o.isCorrect,
    );
  }
}
