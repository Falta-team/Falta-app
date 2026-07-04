import 'package:flutter/material.dart';

/// Main screen for the Exams feature.
class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  static const String routeName = '/exams';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: const Center(
        child: Text('Exams screen'),
      ),
    );
  }
}
