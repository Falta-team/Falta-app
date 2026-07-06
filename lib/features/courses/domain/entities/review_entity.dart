/// Entity representing a student [Review] on a course.
class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.name,
    required this.comment,
    required this.avatarPath,
  });

  final String id;
  final String name;
  final String comment;
  final String avatarPath;
}
