/// A teacher saved to the user's favorites (grid tab "المدرسين").
class FavoriteTeacherEntity {
  const FavoriteTeacherEntity({
    required this.id,
    required this.name,
    required this.bio,
    required this.price,
    required this.rating,
    required this.image,
  });

  final String id;
  final String name;
  final String bio;
  final int price;
  final double rating;
  final String image;
}

/// A course lesson saved to the user's favorites (list tab "الكورسات").
class FavoriteLessonEntity {
  const FavoriteLessonEntity({
    required this.id,
    required this.lessonTitle,
    required this.subject,
    required this.teacherName,
    required this.image,
  });

  final String id;

  /// e.g. "الدرس الاول"
  final String lessonTitle;

  /// e.g. "التفاضل والتكامل"
  final String subject;

  final String teacherName;
  final String image;
}
