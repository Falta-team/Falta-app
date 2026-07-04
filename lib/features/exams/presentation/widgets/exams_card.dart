import 'package:flutter/material.dart';

/// A reusable widget for the Exams feature.
///
/// Split UI pieces used by [ExamsScreen] into small
/// widgets like this one and place them in this folder.
class ExamsCard extends StatelessWidget {
  const ExamsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Exams card'),
      ),
    );
  }
}
