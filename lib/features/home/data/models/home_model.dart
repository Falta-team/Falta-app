import 'package:falta_app/features/courses/data/models/courses_model.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';

/// Data model for the Home dashboard.
///
/// Composes the three raw API responses (`/users/profile`, `/courses`,
/// `/subscriptions/status`) into a single [HomeEntity]. This is the only
/// layer allowed to know about the raw API field names for this feature.
class HomeModel extends HomeEntity {
  const HomeModel({
    required super.userName,
    required super.userAvatar,
    required super.featuredCourses,
    required super.subscriptionActive,
  });

  /// Builds a [HomeModel] out of the three already-decoded JSON responses.
  ///
  /// [subscriptionJson] is optional — the subscription badge is a "nice to
  /// have", so a failed/missing subscription call should not break the
  /// whole dashboard.
  factory HomeModel.fromResponses({
    required Map<String, dynamic> profileJson,
    required List<dynamic> coursesJson,
    Map<String, dynamic>? subscriptionJson,
    int featuredLimit = 6,
  }) {
    final dynamic profileDataRaw =
        profileJson['data'] ?? profileJson['user'] ?? profileJson;
    final Map<String, dynamic> profileData =
        profileDataRaw is Map<String, dynamic> ? profileDataRaw : const {};

    final String firstName = profileData['firstName']?.toString() ?? '';
    final String lastName = profileData['lastName']?.toString() ?? '';
    final String fullName = '$firstName $lastName'.trim();

    final featuredCourses = coursesJson
        .whereType<Map<String, dynamic>>()
        .map((e) => CoursesModel.fromJson(e))
        .take(featuredLimit)
        .toList();

    bool subscriptionActive = false;
    if (subscriptionJson != null) {
      final dynamic subDataRaw =
          subscriptionJson['data'] ?? subscriptionJson;
      final Map<String, dynamic> subData =
          subDataRaw is Map<String, dynamic> ? subDataRaw : const {};

      subscriptionActive = subData['active'] as bool? ??
          subData['isActive'] as bool? ??
          (subData['status']?.toString().toLowerCase() == 'active');
    }

    return HomeModel(
      userName: fullName.isNotEmpty
          ? fullName
          : (profileData['name']?.toString() ?? ''),
      userAvatar: profileData['avatar']?.toString() ??
          profileData['image']?.toString() ??
          '',
      featuredCourses: featuredCourses,
      subscriptionActive: subscriptionActive,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userName': userName,
      'userAvatar': userAvatar,
      'featuredCourses': featuredCourses
          .whereType<CoursesModel>()
          .map((c) => c.toJson())
          .toList(),
      'subscriptionActive': subscriptionActive,
    };
  }
}
