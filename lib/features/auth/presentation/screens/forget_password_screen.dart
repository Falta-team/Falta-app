import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSend(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ForgotPasswordEvent(
        phoneNumber: '+970${_phoneController.text.trim()}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Success → OTP ────────────────────────────────────────────────
          if (state is ForgotPasswordSuccessState) {
            Navigator.pushNamed(
              context,
              '/otp_verify_screen',
              arguments: state.phoneNumber,
            );
          }
          // ── Failure → SnackBar ────────────────────────────────────────────
          if (state is ForgotPasswordFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;

          return SafeArea(
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
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back),
                              ),
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
                          const Spacer(),
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
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الجوال';
                          }
                          if (v.trim().length < 9) return 'رقم غير صحيح';
                          return null;
                        },
                      ),
                      32.hs,
                      CustomButton(
                        text: 'ارسال',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : () => _onSend(context),
                      ),
                      24.hs,
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
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
          );
        },
      ),
    );
  }
}


