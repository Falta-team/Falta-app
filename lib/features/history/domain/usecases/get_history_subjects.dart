import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/repositories/history_repository.dart';

class GetHistorySubjects {
  const GetHistorySubjects(this._repository);

  final HistoryRepository _repository;

  Future<List<HistorySubjectEntity>> call() => _repository.getSubjects();
}
