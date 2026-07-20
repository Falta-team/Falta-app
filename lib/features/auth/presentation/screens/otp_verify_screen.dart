import 'dart:async';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  final OtpFlowType flowType;

  const OtpVerifyScreen({super.key, this.phoneNumber = '+970 597559410',this.flowType = OtpFlowType.forgotPassword,});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _pinController = TextEditingController();
  final _focusNode     = FocusNode();
  final _formKey       = GlobalKey<FormState>();

  int  _secondsLeft = 60;
  Timer? _timer;
  bool _hasError    = false;

  // phone passed from route arguments OR widget param
  late String _phone;

  @override
  void initState() {
    super.initState();
    _phone = widget.phoneNumber;
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pick up phone from route arguments if passed
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) _phone = args;
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft == 0) { t.cancel(); return; }
      setState(() => _secondsLeft--);
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onVerify(BuildContext context) {
    if (_pinController.text.length < 4) return;
    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        phoneNumber: _phone,
        code:        _pinController.text,
        flowType:    widget.flowType,
      ),
    );

  }

  void _onResend(BuildContext context) {
    if (_secondsLeft > 0) return;
    _pinController.clear();
    setState(() => _hasError = false);
    _startTimer();
    context.read<AuthBloc>().add(ForgotPasswordEvent(phoneNumber: _phone));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final textColor    = isDark ? AppColors.textLight       : AppColors.textDark;
    final subtextColor = isDark ? AppColors.textSecondaryDark: AppColors.textSecondaryLight;
    final boxBg        = isDark ? AppColors.card2Dark       : Colors.white;
    final boxBorder    = isDark ? AppColors.borderDark      : AppColors.borderLight;

    final defaultTheme = PinTheme(
      width: 64, height: 64,
      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
          color: textColor, fontFamily: 'Cairo'),
      decoration: BoxDecoration(color: boxBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: boxBorder, width: 1.5)),
    );

    final focusedTheme   = defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 2));
    final submittedTheme = defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.primary.withOpacity(0.08));
    final errorTheme     = defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.error, width: 2),
        color: AppColors.error.withOpacity(0.06));

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Success → Reset Password ────────────────────────────────────
          if (state is VerifyOtpSuccessState) {
            Navigator.pushNamed(
              context,
              '/reset_password_screen',
              arguments: {
                'phoneNumber': state.phoneNumber,
                'code':        state.code,
              },
            );
          }
          // ── Failure → show error on pinput ─────────────────────────────
          if (state is VerifyOtpFailureState) {
            setState(() => _hasError = true);
            _formKey.currentState?.validate();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.hs,
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_forward,
                        color: textColor,
                        size: 28,
                      ),
                    ),
                    40.hs,
                    RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'قمنا بإرسال رسالة SMS قصيرة تحتوي على رمز التفعيل لرقمك ',
                            style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          TextSpan(
                            text: _phone,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    40.hs,

                    // ── Pinput ───────────────────────────────────────────
                    Form(
                      key: _formKey,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 4,
                          controller: _pinController,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          defaultPinTheme: defaultTheme,
                          focusedPinTheme: focusedTheme,
                          submittedPinTheme: submittedTheme,
                          errorPinTheme: errorTheme,
                          showCursor: true,
                          cursor: Container(
                              width: 2, height: 24, color: AppColors.primary),
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          validator: (_) => _hasError ? 'الرمز غير صحيح' : null,
                          onCompleted: (_) => _onVerify(context),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ),
                    ),

                    if (_hasError) ...[
                      10.hs,
                      Row(
                        children: const [
                          Icon(Icons.error_outline, color: AppColors.error, size: 16),
                          SizedBox(width: 6),
                          Text('الرمز المدخل غير صحيح، حاول مجدداً',
                              style: TextStyle(color: AppColors.error,
                                  fontSize: 13, fontFamily: 'Cairo')),
                        ],
                      ),
                    ],

                    32.hs,
                    CustomButton(
                      text: 'تحقق',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _onVerify(context),
                    ),
                    20.hs,
                    Center(
                      child: GestureDetector(
                        onTap: () => _onResend(context),
                        child: Text(
                          _secondsLeft > 0
                              ? 'إعادة إرسال الرمز في $_timerText'
                              : 'إعادة إرسال الرمز',
                          style: TextStyle(
                            fontSize: 14, fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                            color: _secondsLeft > 0
                                ? AppColors.primary
                                : subtextColor,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
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
