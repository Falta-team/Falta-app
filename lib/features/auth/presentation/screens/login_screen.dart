import 'package:falta_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/features/home/presentation/screens/home_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 90, height: 70),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.arrow_forward),
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
                ],
              ),
              36.hs,
              Text(
                'رقم الجوال',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇵🇸'),
                        8.ws,
                        const Text(
                          '970',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              24.hs,
              const Text(
                'كلمة المرور',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
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
                ),
              ),
              14.hs,
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
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
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
              ),
              20.hs,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'قم بتسجيل جديد الآن',
                      style: TextStyle(
                        color: Color(0xff49B000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    ' ليس لديك حساب؟',
                    style: TextStyle(color: Colors.grey),
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
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'بالنقر فوق زر تسجيل الدخول، فإنك توافق على ',
                        ),
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
  }
}
