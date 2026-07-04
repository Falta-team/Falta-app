import 'package:falta_app/features/ai/domain/entities/ai_entity.dart';
import 'package:falta_app/features/ai/domain/repositories/ai_repository.dart';

/// Use case that fetches all Ai items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetAi`, `AddAi`, ...).
class GetAi {
  const GetAi(this._repository);

  final AiRepository _repository;

  Future<List<AiEntity>> call() {
    return _repository.getAll();
  }
}
