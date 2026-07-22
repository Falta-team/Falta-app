import 'package:falta_app/features/history/domain/entities/history_entities.dart';

abstract class HistoryRepository {
  Future<List<HistorySubjectEntity>> getSubjects();

  Future<HistoryRecordEntity> getRecord(String subjectId);

  /// Recent attempt percentages (0–100), oldest → newest, capped at [limit].
  Future<List<double>> getRecentPercentages({int limit = 7});
}
