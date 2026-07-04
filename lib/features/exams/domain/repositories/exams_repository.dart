import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';

/// Abstract contract for the Exams feature.
///
/// The implementation lives in the data layer
/// (`exams_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class ExamsRepository {
  Future<List<ExamsEntity>> getAll();
}
