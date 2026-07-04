import 'package:flutter/material.dart';

/// Main screen for the Courses feature.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  static const String routeName = '/courses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: const Center(
        child: Text('Courses screen'),
      ),
    );
  }
}
