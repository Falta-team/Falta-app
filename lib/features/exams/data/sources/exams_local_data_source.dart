import 'package:falta_app/features/exams/data/models/exam_question_model.dart';
import 'package:falta_app/features/exams/data/models/exam_unit_model.dart';

class ExamsLocalDataSource {
  const ExamsLocalDataSource();

  Future<List<ExamUnitModel>> getUnits({required int semester}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final suffix = semester == 1 ? 'أ' : 'ب';
    return [
      ExamUnitModel.fromJson({
        'id': 'u1_$semester',
        'title': 'الوحدة الأولى :',
        'subtitle': '(حساب التفاضل)',
        'isExpanded': true,
        'isSelected': true,
        'lessons': [
          {
            'id': 'l1_$semester',
            'title': 'متوسط التغير $suffix',
            'isSelected': true,
          },
          {
            'id': 'l2_$semester',
            'title': 'متوسط التغير',
            'isSelected': false,
          },
          {
            'id': 'l3_$semester',
            'title': 'متوسط التغير',
            'isSelected': false,
          },
          {
            'id': 'l4_$semester',
            'title': 'متوسط التغير',
            'isSelected': false,
          },
        ],
      }),
      ExamUnitModel.fromJson({
        'id': 'u2_$semester',
        'title': 'الوحدة الثانية :',
        'subtitle': '(قواعد الاشتقاق)',
        'isExpanded': false,
        'isSelected': true,
        'lessons': [
          {
            'id': 'l5_$semester',
            'title': 'قاعدة القوة',
            'isSelected': false,
          },
          {
            'id': 'l6_$semester',
            'title': 'قاعدة الضرب',
            'isSelected': false,
          },
        ],
      }),
      ExamUnitModel.fromJson({
        'id': 'u3_$semester',
        'title': 'الوحدة الثانية :',
        'subtitle': '(قواعد الاشتقاق)',
        'isExpanded': false,
        'isSelected': false,
        'lessons': [
          {
            'id': 'l7_$semester',
            'title': 'قاعدة القسمة',
            'isSelected': false,
          },
        ],
      }),
      ExamUnitModel.fromJson({
        'id': 'u4_$semester',
        'title': 'الوحدة الثانية :',
        'subtitle': '(قواعد الاشتقاق)',
        'isExpanded': false,
        'isSelected': false,
        'lessons': [
          {
            'id': 'l8_$semester',
            'title': 'قاعدة السلسلة',
            'isSelected': false,
          },
        ],
      }),
    ];
  }

  Future<List<ExamQuestionModel>> getQuestions({
    required List<String> lessonIds,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    const optionText = 'يمكن أن يشفر أكثر من حمض أميني.';
    return List<ExamQuestionModel>.generate(20, (index) {
      final id = 'q${index + 1}';
      return ExamQuestionModel.fromJson({
        'id': id,
        'text': 'أي الآتية ليست من خصائص الكودون :',
        'options': [
          {'id': '${id}_a', 'text': optionText, 'isCorrect': true},
          {'id': '${id}_b', 'text': optionText, 'isCorrect': false},
          {'id': '${id}_c', 'text': optionText, 'isCorrect': false},
          {'id': '${id}_d', 'text': optionText, 'isCorrect': false},
        ],
      });
    });
  }
}
