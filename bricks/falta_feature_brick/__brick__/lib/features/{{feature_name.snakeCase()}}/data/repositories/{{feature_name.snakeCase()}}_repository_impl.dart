import 'package:falta_app/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_model.dart';
import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';
import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';

/// Concrete implementation of [{{feature_name.pascalCase()}}Repository].
///
/// Replace the TODOs below with real calls to your API client / local
/// storage / Firebase, etc.
class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  const {{feature_name.pascalCase()}}RepositoryImpl();

  @override
  Future<List<{{feature_name.pascalCase()}}Entity>> getAll() async {
    // TODO(falta_app): replace with a real data source call.
    final List<{{feature_name.pascalCase()}}Model> rawData = <{{feature_name.pascalCase()}}Model>[];
    return rawData;
  }
}
