import 'package:falta_app/features/exams/data/models/exams_model.dart';
import 'package:falta_app/features/exams/data/sources/exams_local_data_source.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_unit_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  const ExamsRepositoryImpl({
    this.localDataSource = const ExamsLocalDataSource(),
  });

  final ExamsLocalDataSource localDataSource;

  @override
  Future<List<ExamsEntity>> getAll() async {
    final List<ExamsModel> rawData = <ExamsModel>[];
    return rawData;
  }

  @override
  Future<List<ExamUnitEntity>> getUnits({required int semester}) {
    return localDataSource.getUnits(semester: semester);
  }

  @override
  Future<List<ExamQuestionEntity>> getQuestions({
    required List<String> lessonIds,
  }) {
    return localDataSource.getQuestions(lessonIds: lessonIds);
  }
}
