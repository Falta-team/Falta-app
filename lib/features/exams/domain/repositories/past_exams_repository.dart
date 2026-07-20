import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';

abstract class PastExamsRepository {
  Future<List<PastExamSubjectEntity>> getSubjects();

  Future<PastExamPaperEntity?> getPaper(String paperId);
}
