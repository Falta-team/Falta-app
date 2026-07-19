import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
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
import 'package:falta_app/features/notifications/service/local_notifications_service.dart';
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:falta_app/features/onboarding/service/onboarding_service.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ init SharedPrefController مرة وحدة هون
  await SharedPrefController().initPreferences();

  // ✅ local notifications (new lessons / comment replies) — respects the
  // toggle in NotificationsScreen via SharedPrefController.
  await LocalNotificationsService().init();

  final bool isFirstTime = await OnboardingService().isFirstLaunch();

  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundAppColor,
        ),
        home: SplashScreen(isFirstTime: isFirstTime),
        routes: {
          '/home':                  (_) => const HomeScreen(),
          '/onBoarding':            (_) => const OnboardingScreen(),
          '/login':                 (_) => const LoginScreen(),
          '/register':              (_) => const RegisterScreen(),
          '/forget_password':       (_) => const ForgotPasswordScreen(),
          '/otp_verify_screen':     (_) => const OtpVerifyScreen(),
          '/reset_password_screen': (_) => const ResetPasswordScreen(),
          '/notifications':         (_) => const NotificationsScreen(),
          '/ai':                    (_) => const FaltaChatAIScreen(),
          '/account':               (_) => const ProfileScreen(),
          '/courses':               (_) => const CoursesScreen(),
          '/exams':                 (_) => const ExamsScreen(),
          '/instructors':           (_) => const InstructorsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == CourseDetailScreen.routeName) {
            final courseId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => CourseDetailScreen(courseId: courseId),
            );
          }
          return null;
        },
      ),
    );
  }
}