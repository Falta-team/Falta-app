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
    required this.rating,
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
  final double rating;
  final double price;
  final bool isPaid;
}
