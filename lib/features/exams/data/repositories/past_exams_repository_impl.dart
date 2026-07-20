import 'package:falta_app/features/exams/data/sources/past_exams_local_data_source.dart';
import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:falta_app/features/exams/domain/repositories/past_exams_repository.dart';

class PastExamsRepositoryImpl implements PastExamsRepository {
  const PastExamsRepositoryImpl({
    this.local = const PastExamsLocalDataSource(),
  });

  final PastExamsLocalDataSource local;

  @override
  Future<List<PastExamSubjectEntity>> getSubjects() => local.getSubjects();

  @override
  Future<PastExamPaperEntity?> getPaper(String paperId) =>
      local.getPaper(paperId);
}
