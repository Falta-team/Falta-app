/// Entity representing a [Courses] in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP). Add the fields relevant to this
/// feature below.
class CoursesEntity {
  const CoursesEntity({
    required this.id,
  });

  final String id;
}
