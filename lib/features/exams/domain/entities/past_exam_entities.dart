/// Ordered multiple-choice option (أ ب ج د).
class PastExamOptionEntity {
  const PastExamOptionEntity({
    required this.label,
    required this.text,
    this.isCorrect = false,
  });

  /// Arabic letter label: أ، ب، ج، د
  final String label;
  final String text;
  final bool isCorrect;
}

/// Single item inside a question section.
/// [order] controls vertical arrangement (1, 2, 3...).
class PastExamQuestionEntity {
  const PastExamQuestionEntity({
    required this.id,
    required this.order,
    required this.text,
    required this.options,
  });

  final String id;

  /// 1-based display order within the section.
  final int order;
  final String text;

  /// Exactly 4 options rendered as RTL 2×2: أ ب / ج د
  final List<PastExamOptionEntity> options;
}

/// A numbered section (السؤال الأول) that contains many MCQ items.
class PastExamSectionEntity {
  const PastExamSectionEntity({
    required this.id,
    required this.order,
    required this.title,
    required this.instruction,
    required this.questions,
  });

  final String id;
  final int order;
  final String title;
  final String instruction;

  /// Questions sorted by [PastExamQuestionEntity.order].
  final List<PastExamQuestionEntity> questions;

  List<PastExamQuestionEntity> get sortedQuestions {
    final copy = [...questions]..sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }
}

/// One past-year paper (اختبار سنة 2019/2010).
class PastExamPaperEntity {
  const PastExamPaperEntity({
    required this.id,
    required this.yearLabel,
    required this.imageAsset,
    required this.sections,
  });

  final String id;
  final String yearLabel;
  final String imageAsset;

  /// Sections sorted by [PastExamSectionEntity.order] → pagination 1,2,3...
  final List<PastExamSectionEntity> sections;

  List<PastExamSectionEntity> get sortedSections {
    final copy = [...sections]..sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }
}

/// Subject accordion / chip group.
class PastExamSubjectEntity {
  const PastExamSubjectEntity({
    required this.id,
    required this.name,
    required this.papers,
    this.isExpanded = false,
  });

  final String id;
  final String name;
  final List<PastExamPaperEntity> papers;
  final bool isExpanded;

  PastExamSubjectEntity copyWith({bool? isExpanded}) {
    return PastExamSubjectEntity(
      id: id,
      name: name,
      papers: papers,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
