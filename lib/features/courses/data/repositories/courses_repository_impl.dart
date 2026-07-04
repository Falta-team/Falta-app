import 'package:falta_app/features/courses/data/models/courses_model.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';

/// Concrete implementation of [CoursesRepository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl();

  @override
  Future<List<CoursesEntity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<CoursesModel> rawData = <CoursesModel>[];
    return rawData;
  }
}
