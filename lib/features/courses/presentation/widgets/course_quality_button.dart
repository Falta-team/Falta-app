import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Video quality selector (mocked — API exposes a single URL per video,
/// so all options currently play the same source).
class CourseQualityButton extends StatelessWidget {
  final String selectedQuality;
  final List<String> options;
  final Color color;
  final ValueChanged<String> onSelected;

  const CourseQualityButton({
    super.key,
    required this.selectedQuality,
    required this.options,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedQuality,
      onSelected: onSelected,
      color: Colors.black87,
      itemBuilder: (context) => options
          .map(
            (q) => PopupMenuItem(
          value: q,
          child: Text(
            q,
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
          Icon(Icons.hd_outlined, color: color, size: 20),
          2.ws,
          Text(
            selectedQuality,
            style: TextStyle(color: color, fontSize: 11, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}