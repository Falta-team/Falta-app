class CourseMaterialEntity {
  const CourseMaterialEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.fileUrl,
    required this.materialType,
    this.description = '',
    this.sequenceOrder = 0,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final String fileUrl;
  final String materialType;
  final int sequenceOrder;

  bool get isPdf => materialType.toLowerCase() == 'pdf';
}
