import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';

/// Use case that fetches all Home items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetHome`, `AddHome`, ...).
class GetHome {
  const GetHome(this._repository);

  final HomeRepository _repository;

  Future<List<HomeEntity>> call() {
    return _repository.getAll();
  }
}
