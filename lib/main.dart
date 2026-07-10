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
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:falta_app/features/onboarding/service/onboarding_service.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // ── ProviderScope wraps the whole app once, at the very root, so any
  // widget can reach Riverpod providers (coursesListProvider,
  // homeDashboardProvider, etc.) via ref.watch(...) / ref.read(...).
  // Auth still uses flutter_bloc — only courses & home were migrated to
  // Riverpod — so MultiBlocProvider stays nested just below it.
  //
  // Riverpod 3.x auto-retries a failing provider (exponential backoff,
  // up to 10 attempts) by default. Our courses/home providers throw
  // user-facing Arabic errors (e.g. "يجب تسجيل الدخول أولاً") that should
  // surface immediately instead of silently retrying for ~30s first, so
  // retry is disabled app-wide to match the old BLoC's fail-fast
  // behavior. See https://riverpod.dev/docs/3.0_migration.
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
      // Provided once at the root so every screen can reach the bloc it
      // needs via context.read<...>() / BlocConsumer<...>.
      // CoursesBloc and HomeBloc were removed — those two features now
      // run on Riverpod (see courses_provider.dart / home_provider.dart),
      // no BlocProvider registration needed for them anymore.
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
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
          // InstructorsScreen reads its subject label/slug straight off
          // ModalRoute.settings.arguments itself, so no need to unpack
          // the arguments map here anymore.
          '/instructors':            (_) => const InstructorsScreen(),
        },
        // Route with arguments (course detail) — receives the real course
        // id (String) via navigation arguments, the screen fetches the
        // rest through courseDetailsProvider (Riverpod).
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
