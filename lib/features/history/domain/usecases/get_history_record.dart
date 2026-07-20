import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/repositories/history_repository.dart';

class GetHistoryRecord {
  const GetHistoryRecord(this._repository);

  final HistoryRepository _repository;

  Future<HistoryRecordEntity> call(String subjectId) =>
      _repository.getRecord(subjectId);
}
