// import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
// import 'package:falta_app/features/profile/domain/repositories/profile_repository.dart';
// import 'package:falta_app/features/profile/domain/usecases/get_profile.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class _MockProfileRepository extends Mock
//     implements ProfileRepository {}
//
// void main() {
//   group('GetProfile', () {
//     late ProfileRepository repository;
//     late GetProfile usecase;
//
//     setUp(() {
//       repository = _MockProfileRepository();
//       usecase = GetProfile(repository);
//     });
//
//     test('returns list of ProfileEntity from repository', () async {
//       final List<ProfileEntity> expected = <ProfileEntity>[
//         const ProfileEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<ProfileEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
