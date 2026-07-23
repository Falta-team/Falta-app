import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/formatters/phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _nameController    = TextEditingController();
  final _passwordController= TextEditingController();
  final _phoneController   = TextEditingController();

  String? selectedBranch;
  final List<String> branches = ['علمي', 'أدبي'];

  // Map Arabic → API value
  String _branchApiValue(String? branch) {
    if (branch == 'أدبي') return 'literary';
    return 'scientific';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : firstName;

    context.read<AuthBloc>().add(
      RegisterEvent(
        phoneNumber: PhoneFormatter.toApiFormat(_phoneController.text.trim()),
        firstName: firstName,
        lastName: lastName,
        password: _passwordController.text,
        academicBranch: _branchApiValue(selectedBranch),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F7),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Success → OTP ────────────────────────────────────────────────
          if (state is RegisterSuccessState) {
            Navigator.pushNamed(
              context,
              '/otp_verify_screen',
              arguments: state.phoneNumber,
            );
          }
          // ── Failure → SnackBar ────────────────────────────────────────────
          if (state is RegisterFailureState) {
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  // RTL: start = يمين
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.hs,
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
                              'إنشاء حساب',
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
                    20.hs,

                    // ── Full Name ──────────────────────────────────────────
                    const Text("الاسم كامل"),
                    8.hs,
                    CustomTextField(
                      controller: _nameController,
                      hintText: "أدخل الاسم كامل",
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    20.hs,

                    // ── Branch ─────────────────────────────────────────────
                    const Text("الفرع الخاص بك"),
                    8.hs,
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: DropdownButtonFormField<String>(
                        value: selectedBranch,
                        decoration: InputDecoration(
                          hintText: "اختر الفرع الخاص بك",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: branches.map((branch) {
                          return DropdownMenuItem(
                            value: branch,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(branch, textAlign: TextAlign.right),
                          );
                        }).toList(),
                        validator: (v) =>
                        v == null ? 'الرجاء اختيار الفرع' : null,
                        onChanged: (value) =>
                            setState(() => selectedBranch = value),
                      ),
                    ),
                    20.hs,

                    // ── Password ───────────────────────────────────────────
                    const Text("كلمة المرور"),
                    8.hs,
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomPasswordField(
                        controller: _passwordController,
                        hintText: "أدخل كلمة المرور الخاصة بك",
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (v.length < 8) {
                            return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                          }
                          final hasLetter = RegExp(r'[A-Za-z\u0600-\u06FF]')
                              .hasMatch(v);
                          final hasDigit = RegExp(r'\d').hasMatch(v);
                          if (!hasLetter || !hasDigit) {
                            return 'كلمة المرور يجب أن تحتوي على حروف وأرقام';
                          }
                          return null;
                        },
                      ),
                    ),
                    20.hs,

                    // ── Phone ──────────────────────────────────────────────
                    const Text("رقم الجوال"),
                    8.hs,
                    CustomTextField(
                      controller: _phoneController,
                      hintText: "597165369",
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
                            const Text("🇵🇸"),
                            8.ws,
                            const Text("970",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                )),
                          ],
                        ),
                      ),
                    ),
                    40.hs,

                    // ── Submit ─────────────────────────────────────────────
                    CustomButton(
                      text: 'إنشاء حساب',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submit(context),
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