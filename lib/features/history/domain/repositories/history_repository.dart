import 'package:falta_app/features/history/domain/entities/history_entities.dart';

abstract class HistoryRepository {
  Future<List<HistorySubjectEntity>> getSubjects();

  Future<HistoryRecordEntity> getRecord(String subjectId);
}
