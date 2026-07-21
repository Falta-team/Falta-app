import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Playback speed selector (0.5x / 1.0x / 1.5x / 2.0x).
class CourseSpeedButton extends StatelessWidget {
  final double playbackSpeed;
  final List<double> options;
  final Color color;
  final ValueChanged<double> onSelected;

  const CourseSpeedButton({
    super.key,
    required this.playbackSpeed,
    required this.options,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: playbackSpeed,
      onSelected: onSelected,
      color: Colors.black87,
      itemBuilder: (context) => options
          .map(
            (s) => PopupMenuItem(
          value: s,
          child: Text(
            '${s}x',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, color: color, size: 20),
          2.ws,
          Text(
            '${playbackSpeed}x',
            style: TextStyle(color: color, fontSize: 11, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}