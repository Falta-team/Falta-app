import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "سياسية الخصوصية" screen (Figma node 1:24787).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String routeName = '/privacy';

  static const String _privacyText = '''
شركة تلقاني المتقدمة للاتصالات وتقنية المعلومات تؤمن بأن حماية بياناتك الشخصية هو أمر مهم وتريد أن تحيطك علمًا كمستخدم لموقع/تطبيق تلقاني بكيفية جمع واستخدام ومعالجة وكشف معلوماتك الشخصية وبآلية السرية والخصوصية المعمول بها في موقع/تطبيق تلقاني.

يرجى قراءة سياسة الخصوصية هذه، حيث أن بولوجكم إلى تلقاني واستخدامكم له فإن جميع معلوماتكم تخضع لهذه السياسة.

تغطي سياسة الخصوصية هذه المعلومات التي يحصل تلقاني ويحتفظ بها في أنظمته الإلكترونية وهي:
• المعلومات الشخصية التي تقدمها لنا.
• معلومات يتم جمعها تلقائيا عند استخدامك لخدمات تلقاني.
• المعلومات الشخصية التي تكون من مصادر خارجية.

المعلومات الشخصية التي تقدمها لنا
المعلومات الشخصية هي معلومات ذات طابع شخصي يمكن من خلالها التعرف عليك عند استخدامك لخدمات موقع/تطبيق تلقاني.

بيانات الحساب: عندما تقوم بالتسجيل للحصول على حساب معنا، فإننا نطلب منك معلومات شخصية معينة لفتح حسابك، على سبيل المثال: اسمك وعنوان بريدك الإلكتروني.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'سياسية الخصوصية'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Text(
          _privacyText.trim(),
          textAlign: TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xCC000000),
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
