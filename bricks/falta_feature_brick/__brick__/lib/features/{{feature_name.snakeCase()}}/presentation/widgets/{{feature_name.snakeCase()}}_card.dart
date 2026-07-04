import 'package:flutter/material.dart';

/// A reusable widget for the {{feature_name.pascalCase()}} feature.
///
/// Split UI pieces used by [{{feature_name.pascalCase()}}Screen] into small
/// widgets like this one and place them in this folder.
class {{feature_name.pascalCase()}}Card extends StatelessWidget {
  const {{feature_name.pascalCase()}}Card({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('{{feature_name.titleCase()}} card'),
      ),
    );
  }
}
