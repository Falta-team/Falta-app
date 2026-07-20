import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case that fetches the favorite teachers (grid tab).
class GetFavoriteTeachers {
  const GetFavoriteTeachers(this._repository);

  final ProfileRepository _repository;

  Future<List<FavoriteTeacherEntity>> call() {
    return _repository.getFavoriteTeachers();
  }
}

/// Use case that fetches the favorite course lessons (list tab).
class GetFavoriteLessons {
  const GetFavoriteLessons(this._repository);

  final ProfileRepository _repository;

  Future<List<FavoriteLessonEntity>> call() {
    return _repository.getFavoriteLessons();
  }
}
