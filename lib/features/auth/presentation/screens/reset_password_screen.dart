import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  /// Can also be supplied directly (e.g. from a deep link), otherwise
  /// they're picked up from the route arguments passed by OtpVerifyScreen.
  final String? phoneNumber;
  final String? code;

  const ResetPasswordScreen({super.key, this.phoneNumber, this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // phone/code passed from route arguments OR widget params
  late String _phone;
  late String _code;

  @override
  void initState() {
    super.initState();
    _phone = widget.phoneNumber ?? '';
    _code = widget.code ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pick up phone/code from route arguments if passed (Map from OtpVerifyScreen)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final phoneArg = args['phoneNumber'];
      final codeArg = args['code'];
      if (phoneArg is String && phoneArg.isNotEmpty) _phone = phoneArg;
      if (codeArg is String && codeArg.isNotEmpty) _code = codeArg;
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ResetPasswordEvent(
        phoneNumber: _phone,
        code: _code,
        newPassword: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Success → Login ─────────────────────────────────────────────
          if (state is ResetPasswordSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
            );
          }
          // ── Failure → SnackBar ───────────────────────────────────────────
          if (state is ResetPasswordFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                  child: SingleChildScrollView(
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
                                  'كلمة مرور جديدة',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
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
                        const Text(
                          'كلمة المرور الجديدة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        8.hs,
                        CustomPasswordField(
                          controller: _passwordCtrl,
                          hintText: 'ادخل كلمة المرور الخاصة بك',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (v.length < 8) {
                              return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        20.hs,
                        const Text(
                          'تأكيد كلمة المرور الخاصة بك',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        8.hs,
                        CustomPasswordField(
                          controller: _confirmCtrl,
                          hintText: 'تأكيد كلمة المرور الخاصة بك',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'الرجاء تأكيد كلمة المرور';
                            }
                            if (v != _passwordCtrl.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }
                            return null;
                          },
                        ),
                        36.hs,
                        CustomButton(
                          text: 'تأكيد',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : () => _onSubmit(context),
                        ),
                        24.hs,
                      ],
                    ),
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