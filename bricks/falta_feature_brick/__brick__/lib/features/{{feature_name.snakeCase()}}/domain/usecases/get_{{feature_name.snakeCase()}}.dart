import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';
import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';

/// Use case that fetches all {{feature_name.pascalCase()}} items.
///
/// Wrap a single, specific business action per use case
/// (e.g. `Get{{feature_name.pascalCase()}}`, `Add{{feature_name.pascalCase()}}`, ...).
class Get{{feature_name.pascalCase()}} {
  const Get{{feature_name.pascalCase()}}(this._repository);

  final {{feature_name.pascalCase()}}Repository _repository;

  Future<List<{{feature_name.pascalCase()}}Entity>> call() {
    return _repository.getAll();
  }
}
