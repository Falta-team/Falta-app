import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_unit_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';

abstract class ExamsRepository {
  Future<List<ExamsEntity>> getAll();

  Future<List<ExamUnitEntity>> getUnits({required int semester});

  Future<List<ExamQuestionEntity>> getQuestions({
    required List<String> lessonIds,
  });
}
