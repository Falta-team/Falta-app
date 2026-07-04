import 'package:falta_app/features/ai/data/models/ai_model.dart';
import 'package:falta_app/features/ai/domain/entities/ai_entity.dart';
import 'package:falta_app/features/ai/domain/repositories/ai_repository.dart';

/// Concrete implementation of [AiRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl();

  @override
  Future<List<AiEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<AiModel> rawData = <AiModel>[];
    return rawData;
  }
}
