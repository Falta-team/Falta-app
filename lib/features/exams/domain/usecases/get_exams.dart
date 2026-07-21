import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

/// Use case that fetches the exams catalog (`GET /exams`), optionally
/// filtered client-side by [subject].
class GetExams {
  const GetExams(this._repository);

  final ExamsRepository _repository;

  Future<List<ExamsEntity>> call({String? subject}) {
    return _repository.getExams(subject: subject);
  }
}
