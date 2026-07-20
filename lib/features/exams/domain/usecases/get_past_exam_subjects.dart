import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:falta_app/features/exams/domain/repositories/past_exams_repository.dart';

class GetPastExamSubjects {
  const GetPastExamSubjects(this._repository);

  final PastExamsRepository _repository;

  Future<List<PastExamSubjectEntity>> call() => _repository.getSubjects();
}
