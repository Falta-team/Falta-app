import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

/// Use case that fetches all Exams items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetExams`, `AddExams`, ...).
class GetExams {
  const GetExams(this._repository);

  final ExamsRepository _repository;

  Future<List<ExamsEntity>> call() {
    return _repository.getAll();
  }
}
