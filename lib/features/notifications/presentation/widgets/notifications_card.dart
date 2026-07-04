import 'package:flutter/material.dart';

/// A reusable widget for the Notifications feature.
///
/// Split UI pieces used by [NotificationsScreen] into small
/// widgets like this one and place them in this folder.
class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Notifications card'),
      ),
    );
  }
}
