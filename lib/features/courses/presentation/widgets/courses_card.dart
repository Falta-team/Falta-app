import 'package:flutter/material.dart';

/// A reusable widget for the Courses feature.
///
/// Split UI pieces used by [CoursesScreen] into small
/// widgets like this one and place them in this folder.
class CoursesCard extends StatelessWidget {
  const CoursesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Courses card'),
      ),
    );
  }
}
