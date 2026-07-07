import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

/// Entity representing the composed Home dashboard.
///
/// There is no dedicated `/home` endpoint on the API, so this entity is
/// assembled in the data layer from `/users/profile`, `/courses`, and
/// `/subscriptions/status`.
class HomeEntity {
  const HomeEntity({
    required this.userName,
    required this.userAvatar,
    required this.featuredCourses,
    required this.subscriptionActive,
  });

  final String userName;
  final String userAvatar;
  final List<CoursesEntity> featuredCourses;
  final bool subscriptionActive;
}
