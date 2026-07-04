// import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
// import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';
// import 'package:falta_app/features/notifications/domain/usecases/get_notifications.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// class _MockNotificationsRepository extends Mock
//     implements NotificationsRepository {
//   @override
//   Future<List<NotificationsEntity>> getAll() {
//     // TODO: implement getAll
//     throw UnimplementedError();
//   }}
//
//
//
// void main() {
//   group('GetNotifications', () {
//     late NotificationsRepository repository;
//     late GetNotifications usecase;
//
//     setUp(() {
//       repository = _MockNotificationsRepository();
//       usecase = GetNotifications(repository);
//     });
//
//     test('returns list of NotificationsEntity from repository', () async {
//       final List<NotificationsEntity> expected = <NotificationsEntity>[
//         const NotificationsEntity(id: '1'),
//       ];
//       when(() => repository.getAll()).thenAnswer((_) async => expected);
//
//       final List<NotificationsEntity> result = await usecase();
//
//       expect(result, expected);
//       verify(() => repository.getAll()).called(1);
//     });
//   });
// }
