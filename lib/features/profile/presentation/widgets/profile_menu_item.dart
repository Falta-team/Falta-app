import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single row in the account menu: icon (start) + label + chevron (end).
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    required this.iconAsset,
    required this.label,
    super.key,
    this.iconSize = 40,
    this.showChevron = true,
    this.onTap,
  });

  /// SVG asset path (e.g. `assets/icons/profile/ic_settings.svg`).
  final String iconAsset;

  /// Size of the rendered SVG inside the fixed 40x40 slot.
  final double iconSize;

  final String label;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF20283B),
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: Color(0xFF9E9E9E),
              ),
          ],
        ),
      ),
    );
  }
}
