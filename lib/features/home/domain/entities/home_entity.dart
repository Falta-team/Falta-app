import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

class HomeEntity {
  const HomeEntity({
    required this.userName,
    required this.userAvatar,
    required this.featuredCourses,
    required this.subscriptionActive,
    required this.subjects,          // ✅ NEW: distinct subjects from API
  });

  final String userName;
  final String userAvatar;
  final List<CoursesEntity> featuredCourses;
  final bool subscriptionActive;

  /// Distinct subject labels extracted from the courses list.
  /// Used by HomeBodyScreen to render the المواد الدراسية grid
  /// dynamically instead of a hardcoded static list.
  final List<String> subjects;
}