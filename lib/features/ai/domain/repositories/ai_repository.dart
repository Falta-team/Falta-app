import 'package:falta_app/features/ai/domain/entities/ai_entity.dart';

/// Abstract contract for the Ai feature.
///
/// The implementation lives in the data layer
/// (`ai_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class AiRepository {
  Future<List<AiEntity>> getAll();
}
