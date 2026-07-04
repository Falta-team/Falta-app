// import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
// import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';
// import 'package:falta_app/features/exams/domain/usecases/get_exams.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class _MockExamsRepository extends Mock
//     implements ExamsRepository {}
//
// void main() {
//   group('GetExams', () {
//     late ExamsRepository repository;
//     late GetExams usecase;
//
//     setUp(() {
//       repository = _MockExamsRepository();
//       usecase = GetExams(repository);
//     });
//
//     test('returns list of ExamsEntity from repository', () async {
//       final List<ExamsEntity> expected = <ExamsEntity>[
//         const ExamsEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<ExamsEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
