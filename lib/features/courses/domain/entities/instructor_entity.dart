/// Entity representing an [Instructor] in the domain layer.
///
/// Pure business object — no JSON, no HTTP, no Firebase dependencies.
class InstructorEntity {
  const InstructorEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String subtitle;
  final String price;
  final String imagePath;
}
