class ExamLessonEntity {
  const ExamLessonEntity({
    required this.id,
    required this.title,
    this.isSelected = false,
  });

  final String id;
  final String title;
  final bool isSelected;

  ExamLessonEntity copyWith({bool? isSelected}) {
    return ExamLessonEntity(
      id: id,
      title: title,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
