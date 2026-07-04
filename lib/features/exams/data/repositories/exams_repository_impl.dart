import 'package:falta_app/features/exams/data/models/exams_model.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

/// Concrete implementation of [ExamsRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class ExamsRepositoryImpl implements ExamsRepository {
  const ExamsRepositoryImpl();

  @override
  Future<List<ExamsEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<ExamsModel> rawData = <ExamsModel>[];
    return rawData;
  }
}
