import 'package:falta_app/features/home/data/models/home_model.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';

/// Concrete implementation of [HomeRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<List<HomeEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<HomeModel> rawData = <HomeModel>[];
    return rawData;
  }
}
