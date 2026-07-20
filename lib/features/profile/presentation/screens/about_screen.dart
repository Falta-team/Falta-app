import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "حول التطبيق" screen (Figma node 1:24662).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String routeName = '/about';

  static const String _aboutText =
      'شركة تلقاني المتقدمة للاتصالات وتقنية المعلومات تؤمن بأن حماية بياناتك '
      'الشخصية هو أمر مهم وتريد أن تحيطك علمًا كمستخدم لموقع/تطبيق تلقاني بكيفية '
      'جمع واستخدام ومعالجة وكشف معلوماتك الشخصية وبآلية السرية والخصوصية '
      'المعمول بها في موقع/تطبيق تلقاني.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'حول التطبيق'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Image.asset(
                'logo.png'.image_,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تطبيق فلتة',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(icon: Icons.facebook, onTap: () {}),
                const SizedBox(width: 24),
                _SocialButton(icon: Icons.camera_alt_outlined, onTap: () {}),
                const SizedBox(width: 24),
                _SocialButton(icon: Icons.alternate_email, onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _aboutText,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xCC000000),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }
}
