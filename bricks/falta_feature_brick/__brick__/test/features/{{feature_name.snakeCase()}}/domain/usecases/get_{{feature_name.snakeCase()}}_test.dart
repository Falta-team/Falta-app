import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';
import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:falta_app/features/{{feature_name.snakeCase()}}/domain/usecases/get_{{feature_name.snakeCase()}}.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Mock{{feature_name.pascalCase()}}Repository extends Mock
    implements {{feature_name.pascalCase()}}Repository {}

void main() {
  group('Get{{feature_name.pascalCase()}}', () {
    late {{feature_name.pascalCase()}}Repository repository;
    late Get{{feature_name.pascalCase()}} usecase;

    setUp(() {
      repository = _Mock{{feature_name.pascalCase()}}Repository();
      usecase = Get{{feature_name.pascalCase()}}(repository);
    });

    test('returns list of {{feature_name.pascalCase()}}Entity from repository', () async {
      final List<{{feature_name.pascalCase()}}Entity> expected = <{{feature_name.pascalCase()}}Entity>[
        const {{feature_name.pascalCase()}}Entity(id: '1'),
      ];
      when(() => repository.getAll()).thenAnswer((_) async => expected);

      final List<{{feature_name.pascalCase()}}Entity> result = await usecase();

      expect(result, expected);
      verify(() => repository.getAll()).called(1);
    });
  });
}
