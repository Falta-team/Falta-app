/// Entity representing a [{{feature_name.pascalCase()}}] in the domain layer.
///
/// This is a pure business object with no dependency on data sources
/// (no JSON, no Firebase, no HTTP). Add the fields relevant to this
/// feature below.
class {{feature_name.pascalCase()}}Entity {
  const {{feature_name.pascalCase()}}Entity({
    required this.id,
  });

  final String id;
}
