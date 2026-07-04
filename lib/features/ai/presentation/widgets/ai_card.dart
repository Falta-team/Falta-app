import 'package:flutter/material.dart';

/// A reusable widget for the Ai feature.
///
/// Split UI pieces used by [AiScreen] into small
/// widgets like this one and place them in this folder.
class AiCard extends StatelessWidget {
  const AiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Ai card'),
      ),
    );
  }
}
