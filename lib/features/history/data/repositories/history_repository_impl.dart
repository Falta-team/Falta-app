import 'package:falta_app/features/history/data/sources/history_local_data_source.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({HistoryLocalDataSource? dataSource})
      : _dataSource = dataSource ?? HistoryLocalDataSource();

  final HistoryLocalDataSource _dataSource;

  @override
  Future<List<HistorySubjectEntity>> getSubjects() =>
      _dataSource.fetchSubjects();

  @override
  Future<HistoryRecordEntity> getRecord(String subjectId) =>
      _dataSource.fetchRecord(subjectId);
}
