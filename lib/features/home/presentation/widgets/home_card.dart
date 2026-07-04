import 'package:flutter/material.dart';

/// A reusable widget for the Home feature.
///
/// Split UI pieces used by [HomeScreen] into small
/// widgets like this one and place them in this folder.
class HomeCard extends StatelessWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Home card'),
      ),
    );
  }
}
