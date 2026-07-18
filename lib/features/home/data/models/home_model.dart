import 'package:falta_app/features/courses/data/models/courses_model.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.userName,
    required super.userAvatar,
    required super.featuredCourses,
    required super.subscriptionActive,
    required super.subjects,
  });

  factory HomeModel.fromResponses({
    required Map<String, dynamic> profileJson,
    required List<dynamic> coursesJson,
    Map<String, dynamic>? subscriptionJson,
    int featuredLimit = 6,
  }) {
    // ── Profile ────────────────────────────────────────────────────────────
    final dynamic profileDataRaw =
        profileJson['data'] ?? profileJson['user'] ?? profileJson;
    final Map<String, dynamic> profileData =
    profileDataRaw is Map<String, dynamic> ? profileDataRaw : const {};

    final String firstName = profileData['firstName']?.toString() ?? '';
    final String lastName  = profileData['lastName']?.toString()  ?? '';
    final String fullName  = '$firstName $lastName'.trim();

    // ── Courses → featured + subjects ─────────────────────────────────────
    final allCourses = coursesJson
        .whereType<Map<String, dynamic>>()
        .map((e) => CoursesModel.fromJson(e))
        .toList();

    final featuredCourses = allCourses.take(featuredLimit).toList();

    // ✅ Extract distinct subjects in order of first appearance
    final seenSubjects  = <String>{};
    final subjectLabels = <String>[];
    for (final c in allCourses) {
      if (c.subject.isNotEmpty && seenSubjects.add(c.subject)) {
        subjectLabels.add(c.subject);
      }
    }

    // ── Subscription ───────────────────────────────────────────────────────
    bool subscriptionActive = false;
    if (subscriptionJson != null) {
      final dynamic subDataRaw = subscriptionJson['data'] ?? subscriptionJson;
      final Map<String, dynamic> subData =
      subDataRaw is Map<String, dynamic> ? subDataRaw : const {};
      subscriptionActive = subData['active']   as bool? ??
          subData['isActive'] as bool? ??
          (subData['status']?.toString().toLowerCase() == 'active');
    }

    return HomeModel(
      userName: fullName.isNotEmpty
          ? fullName
          : (profileData['name']?.toString() ?? ''),
      userAvatar: profileData['avatar']?.toString() ??
          profileData['image']?.toString() ?? '',
      featuredCourses:    featuredCourses,
      subscriptionActive: subscriptionActive,
      subjects:           subjectLabels,
    );
  }
}