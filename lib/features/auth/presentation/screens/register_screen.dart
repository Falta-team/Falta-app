import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedBranch;

  final List<String> branches = ['علمي', 'أدبي'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              20.hs,
              Row(
                children: [
                  Image.asset("assets/images/logo.png", width: 90, height: 70),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward),
                      36.hs,
                      Text(
                        "تسجيل الدخول",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              20.hs,
              const Text("الاسم كامل"),
              8.hs,
              CustomTextField(
                controller: _nameController,
                hintText: "أدخل الاسم كامل",
              ),
              20.hs,
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
                  return DropdownMenuItem(value: branch,alignment: AlignmentDirectional.centerEnd, child: Text(branch,textAlign: TextAlign.right,));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBranch = value;
                  });
                },
              )),
              20.hs,
              const Text("كلمة المرور"),
              8.hs,
              Directionality(
                textDirection: TextDirection.rtl,
                child: CustomPasswordField(
                  controller: _passwordController,
                  hintText: "أدخل كلمة المرور الخاصة بك",
                ),
              ),

              20.hs,
              const Text("رقم الجوال"),
              8.hs,
              CustomTextField(
                controller: _phoneController,
                hintText: "597165369",
                textAlign: TextAlign.left,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🇵🇸"),
                      8.ws,
                      const Text(
                        "970",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              40.hs,
              CustomButton(text: 'تسجيل دخول', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
