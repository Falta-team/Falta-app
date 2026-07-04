import 'package:flutter/material.dart';

/// A reusable widget for the Profile feature.
///
/// Split UI pieces used by [ProfileScreen] into small
/// widgets like this one and place them in this folder.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Profile card'),
      ),
    );
  }
}
