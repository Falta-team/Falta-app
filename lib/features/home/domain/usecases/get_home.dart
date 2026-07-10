import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';

/// Use case that fetches the composed Home dashboard.
class GetHome {
  const GetHome(this._repository);

  final HomeRepository _repository;

  Future<HomeEntity> call({required String token}) {
    return _repository.getHomeDashboard(token: token);
  }
}
