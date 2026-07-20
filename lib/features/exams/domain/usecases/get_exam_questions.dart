import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

class GetExamQuestions {
  const GetExamQuestions(this._repository);

  final ExamsRepository _repository;

  Future<List<ExamQuestionEntity>> call({required List<String> lessonIds}) {
    return _repository.getQuestions(lessonIds: lessonIds);
  }
}
