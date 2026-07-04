import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that fetches all Profile items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `GetProfile`, `AddProfile`, ...).
class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<List<ProfileEntity>> call() {
    return _repository.getAll();
  }
}
