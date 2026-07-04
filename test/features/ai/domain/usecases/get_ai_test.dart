// import 'package:falta_app/features/ai/domain/entities/ai_entity.dart';
// import 'package:falta_app/features/ai/domain/repositories/ai_repository.dart';
// import 'package:falta_app/features/ai/domain/usecases/get_ai.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class _MockAiRepository extends Mock
//     implements AiRepository {}
//
// void main() {
//   group('GetAi', () {
//     late AiRepository repository;
//     late GetAi usecase;
//
//     setUp(() {
//       repository = _MockAiRepository();
//       usecase = GetAi(repository);
//     });
//
//     test('returns list of AiEntity from repository', () async {
//       final List<AiEntity> expected = <AiEntity>[
//         const AiEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<AiEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
