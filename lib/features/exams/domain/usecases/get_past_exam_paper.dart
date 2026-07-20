import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:falta_app/features/exams/domain/repositories/past_exams_repository.dart';

class GetPastExamPaper {
  const GetPastExamPaper(this._repository);

  final PastExamsRepository _repository;

  Future<PastExamPaperEntity?> call(String paperId) =>
      _repository.getPaper(paperId);
}
