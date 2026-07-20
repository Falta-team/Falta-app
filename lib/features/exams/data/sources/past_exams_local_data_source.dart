import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';

/// Local mock — to add a question, append to `questions` with next `order`.
///
/// Ordering rules:
/// 1. Subject → Papers (years)
/// 2. Paper → Sections (السؤال الأول…) by `order`
/// 3. Section → Questions by `order` (1..n)
/// 4. Options always أ، ب، ج، د (RTL 2×2: أ|ب then ج|د)
class PastExamsLocalDataSource {
  const PastExamsLocalDataSource();

  static const _instruction =
      'يتكون هذا السؤال من 20 فقرة من نوع اختيار من متعدد من أربعة بدائل '
      'اختر رمز الإجابة الصحيحة، ثم انقلها لدفتر إجابتك:';

  static const _qText = 'ما المعنى المستفاد من قوله تعالى : "و غلّقت ؟';

  List<PastExamOptionEntity> _defaultOptions({required int correctIndex}) {
    const texts = ['التدرج', 'التعدية', 'المبالغة', 'السلب'];
    const labels = ['أ', 'ب', 'ج', 'د'];
    return List.generate(
      4,
      (i) => PastExamOptionEntity(
        label: labels[i],
        text: texts[i],
        isCorrect: i == correctIndex,
      ),
    );
  }

  List<PastExamQuestionEntity> _buildQuestions({
    required String sectionId,
    required int count,
  }) {
    return List.generate(count, (i) {
      final order = i + 1;
      return PastExamQuestionEntity(
        id: '${sectionId}_q$order',
        order: order,
        text: _qText,
        options: _defaultOptions(correctIndex: i % 4),
      );
    });
  }

  List<PastExamSectionEntity> _buildSections({required String paperId}) {
    return List.generate(4, (i) {
      final order = i + 1;
      final id = '${paperId}_s$order';
      return PastExamSectionEntity(
        id: id,
        order: order,
        title: 'السؤال ${_arabicOrdinal(order)}:',
        instruction: _instruction,
        questions: _buildQuestions(sectionId: id, count: 5),
      );
    });
  }

  String _arabicOrdinal(int n) {
    const map = {
      1: 'الأول',
      2: 'الثاني',
      3: 'الثالث',
      4: 'الرابع',
    };
    return map[n] ?? '$n';
  }

  PastExamPaperEntity _paper(String id, String year) {
    return PastExamPaperEntity(
      id: id,
      yearLabel: year,
      imageAsset: 'assets/images/exam_year_card.png',
      sections: _buildSections(paperId: id),
    );
  }

  Future<List<PastExamSubjectEntity>> getSubjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final years = [
      '2019/2010',
      '2020/2021',
      '2021/2022',
      '2022/2023',
      '2023/2024',
    ];
    return [
      PastExamSubjectEntity(
        id: 'math',
        name: 'الرياضيات',
        isExpanded: true,
        papers: [
          for (var i = 0; i < years.length; i++)
            _paper('math_$i', years[i]),
        ],
      ),
      for (final name in [
        'العلوم الحياتية',
        'الفيزياء',
        'الكيمياء',
        'اللغة العربية',
        'اللغة الإنجليزية',
      ])
        PastExamSubjectEntity(
          id: name,
          name: name,
          papers: [
            for (var i = 0; i < 3; i++)
              _paper('${name}_$i', years[i]),
          ],
        ),
    ];
  }

  Future<PastExamPaperEntity?> getPaper(String paperId) async {
    final subjects = await getSubjects();
    for (final s in subjects) {
      for (final p in s.papers) {
        if (p.id == paperId) return p;
      }
    }
    return null;
  }
}
