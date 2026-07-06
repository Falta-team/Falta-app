import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/courses_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/instructors_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/home/presentation/screens/home_screen.dart';
import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundAppColor,
      ),
      home: const HomeScreen(),
      routes: {
        '/home':                   (_) => const HomeScreen(),
        '/onBoarding':             (_) => const OnboardingScreen(),
        '/login':                  (_) => const LoginScreen(),
        '/register':               (_) => const RegisterScreen(),
        '/forget_password':        (_) => const ForgotPasswordScreen(),
        '/otp_verify_screen':      (_) => const OtpVerifyScreen(),
        '/reset_password_screen':  (_) => const ResetPasswordScreen(),
        '/notifications':          (_) => const NotificationsScreen(),
        '/ai':                     (_) => const FaltaChatAIScreen(),
        '/account':                (_) => const ProfileScreen(),
        '/courses':                (_) => const CoursesScreen(),
        '/exams':                  (_) => const ExamsScreen(),
        '/instructors': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;
          return InstructorsScreen(subject: args?['label']);
        },
      },
      // Route with arguments (course detail)
      onGenerateRoute: (settings) {
        if (settings.name == '/course-detail') {
          final course = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: course),
          );
        }
        return null;
      },
    );
  }
}