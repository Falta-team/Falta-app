// import 'package:falta_app/features/home/domain/entities/home_entity.dart';
// import 'package:falta_app/features/home/domain/repositories/home_repository.dart';
// import 'package:falta_app/features/home/domain/usecases/get_home.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class _MockHomeRepository extends Mock
//     implements HomeRepository {}
//
// void main() {
//   group('GetHome', () {
//     late HomeRepository repository;
//     late GetHome usecase;
//
//     setUp(() {
//       repository = _MockHomeRepository();
//       usecase = GetHome(repository);
//     });
//
//     test('returns list of HomeEntity from repository', () async {
//       final List<HomeEntity> expected = <HomeEntity>[
//         const HomeEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<HomeEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
