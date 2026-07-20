import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamTimer extends StatelessWidget {
  const ExamTimer({
    required this.remaining,
    required this.total,
    super.key,
  });

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final progress = total.inSeconds == 0
        ? 0.0
        : remaining.inSeconds.clamp(0, total.inSeconds) / total.inSeconds;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFE8E8E8),
              color: AppColors.primary,
            ),
          ),
          Text(
            '$minutes:$seconds',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF070417),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
