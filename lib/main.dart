import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:falta_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_bloc.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_state.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/courses_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/instructors_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/home/presentation/screens/home_screen.dart';
import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:falta_app/features/onboarding/service/onboarding_service.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── One-Time Onboarding: initialize SharedPreferences and read the flag ──
  // before the first frame is drawn, so we know which screen to boot into.
  await SharedPreferences.getInstance();
  final bool isFirstTime = await OnboardingService().isFirstLaunch();

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      // Provided once at the root so every screen (Login, Register,
      // ForgotPassword, OtpVerify, ResetPassword, ...) can reach it via
      // context.read<AuthBloc>() / BlocConsumer<AuthBloc, AuthState>.
      create: (_) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundAppColor,
        ),
        // Splash plays first, then decides on its own where to go next
        // based on isFirstTime: OnboardingScreen or LoginScreen.
        home: SplashScreen(isFirstTime: isFirstTime),
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

            return MaterialPageRoute(
              builder: (_) => CourseDetailScreen(courseId: ,),
            );
          }
          return null;
        },
      ),
    );
  }
}