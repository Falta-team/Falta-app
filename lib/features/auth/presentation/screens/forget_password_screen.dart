import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    // if (!_formKey.currentState!.validate()) return;
    // setState(() => _isLoading = true);
    // // TODO: wire up to backend
    // await Future.delayed(const Duration(seconds: 2));
    // setState(() => _isLoading = false);
    // if (mounted) {
    Navigator.pushNamed(context, '/otp_verify_screen');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.hs,
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_back),
                          36.hs,
                          Text(
                            'نسيت كلمة المرور',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Image.asset(
                        "assets/images/logo.png",
                        width: 90,
                        height: 70,
                      ),
                    ],
                  ),
                  12.hs,
                  Text(
                    'ادخل رقم الجوال المرتبط بحسابك . وسوف نرسل لك رسالة تحتوي على كود لاعادة تعيين كلمة المرور الخاصة بك',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  30.hs,
                  const Text(
                    'رقم الجوال',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  12.hs,
                  CustomTextField(
                    controller: _phoneController,
                    hintText: 'ادخل رقم الجوال الخاص بك',
                  ),
                  32.hs,
                  CustomButton(
                    text: 'ارسال',
                    onPressed: _isLoading ? null : _onSend,
                  ),
                  24.hs,
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondaryLight,
                          ),
                          children: [
                            TextSpan(text: 'ليس لديك حساب؟ '),
                            TextSpan(
                              text: 'قم بتسجيل حديد الآن',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
