/// Entity representing a [Courses] in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP).
class CoursesEntity {
  const CoursesEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.subject,
    required this.instructorId,
    required this.instructorName,
    required this.academicTrack,
    required this.difficultyLevel,
    required this.lessonsCount,
    required this.videoCount,
    required this.rating,
    required this.totalDuration,
    required this.price,
    required this.isPaid,
  });

  final String id;
  final String title;
  final String description;
  final String image;
  final String subject;
  final String instructorId;
  final String instructorName;
  final String academicTrack;
  final String difficultyLevel;
  final int lessonsCount;
  final int videoCount;
  final double rating;
  final int totalDuration;
  final double price;
  final bool isPaid;
}
