import 'package:falta_app/core/navigation/role_home.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/formatters/phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      LoginEvent(
        phoneNumber: PhoneFormatter.toApiFormat(_phoneCtrl.text.trim()),
        password:    _passwordCtrl.text,
      ),

    );
    print(_phoneCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Success → Home ───────────────────────────────────────────────
          if (state is LoginSuccessState) {
            goToRoleHome(context);
          }
          // ── Failure → SnackBar ────────────────────────────────────────────
          if (state is LoginFailureState) {
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

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Column(
                  // RTL: start = يمين
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_forward),
                            ),
                            36.hs,
                            Text(
                              'تسجيل الدخول',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 90,
                          height: 70,
                        ),
                      ],
                    ),
                    36.hs,
                    Text('رقم الجوال',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                    10.hs,
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CustomTextField(
                        controller: _phoneCtrl,
                        hintText: '597165369',
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الجوال';
                          }
                          if (v.trim().length < 9) return 'رقم غير صحيح';
                          return null;
                        },
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇵🇸'),
                              8.ws,
                              const Text('970',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    24.hs,
                    const Text('كلمة المرور',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    10.hs,
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CustomPasswordField(
                        controller: _passwordCtrl,
                        hintText: 'أدخل كلمة المرور الخاصة بك',
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (v.length < 6) return 'كلمة المرور قصيرة جداً';
                          return null;
                        },
                      ),
                    ),
                    14.hs,
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: Color(0xff49B000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    40.hs,
                    CustomButton(
                      text: 'تسجيل الدخول',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submit(context),
                    ),
                    20.hs,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ليس لديك حساب؟ ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            'قم بتسجيل جديد الآن',
                            style: TextStyle(
                              color: Color(0xff49B000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    185.hs,
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style:
                            TextStyle(color: Colors.grey, fontSize: 12),
                            children: [
                              TextSpan(
                                  text:
                                  'بالنقر فوق زر تسجيل الدخول، فإنك توافق على '),
                              TextSpan(
                                text: 'الشروط والأحكام',
                                style: TextStyle(
                                  color: Color(0xff49B000),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '\nوسياسة الخصوصية',
                                style: TextStyle(
                                  color: Color(0xff49B000),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' الخاصة بنا'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
