// import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
// import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
// import 'package:falta_app/features/courses/domain/usecases/get_courses.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class _MockCoursesRepository extends Mock
//     implements CoursesRepository {}
//
// void main() {
//   group('GetCourses', () {
//     late CoursesRepository repository;
//     late GetCourses usecase;
//
//     setUp(() {
//       repository = _MockCoursesRepository();
//       usecase = GetCourses(repository);
//     });
//
//     test('returns list of CoursesEntity from repository', () async {
//       final List<CoursesEntity> expected = <CoursesEntity>[
//         const CoursesEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<CoursesEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
