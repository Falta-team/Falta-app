import 'package:flutter/material.dart';

/// Main screen for the {{feature_name.pascalCase()}} feature.
class {{feature_name.pascalCase()}}Screen extends StatelessWidget {
  const {{feature_name.pascalCase()}}Screen({super.key});

  static const String routeName = '/{{feature_name.paramCase()}}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name.titleCase()}}'),
      ),
      body: const Center(
        child: Text('{{feature_name.titleCase()}} screen'),
      ),
    );
  }
}
