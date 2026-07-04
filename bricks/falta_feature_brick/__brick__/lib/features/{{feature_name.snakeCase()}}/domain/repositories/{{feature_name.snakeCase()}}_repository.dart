import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Abstract contract for the {{feature_name.pascalCase()}} feature.
///
/// The implementation lives in the data layer
/// (`{{feature_name.snakeCase()}}_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class {{feature_name.pascalCase()}}Repository {
  Future<List<{{feature_name.pascalCase()}}Entity>> getAll();
}
