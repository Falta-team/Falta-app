import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/core/theme/app_theme.dart';
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
import 'package:falta_app/features/exams/presentation/screens/exam_session_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_units_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/past_exam_detail_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/past_exams_archive_screen.dart';
import 'package:falta_app/features/history/presentation/screens/history_detail_screen.dart';
import 'package:falta_app/features/history/presentation/screens/history_subjects_screen.dart';
import 'package:falta_app/features/home/presentation/screens/home_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_cards_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_generate_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_shell_screen.dart';
import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:falta_app/features/notifications/service/local_notifications_service.dart';
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:falta_app/features/onboarding/service/onboarding_service.dart';
import 'package:falta_app/features/profile/presentation/screens/about_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/favorites_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/privacy_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/support_screen.dart';
import 'package:falta_app/features/splash/splash_screen.dart';
import 'package:falta_app/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SharedPrefController().initPreferences();
  await LocalNotificationsService().init();
  final isFirstTime = await OnboardingService().isFirstLaunch();

  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isFirstTime});

  final bool isFirstTime;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildFaltaTheme().copyWith(
          scaffoldBackgroundColor: AppColors.backgroundAppColor,
        ),
        locale: const Locale('en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: SplashScreen(isFirstTime: isFirstTime),
        routes: {
          '/home': (_) => const HomeScreen(),
          InstructorShellScreen.routeName: (_) => const InstructorShellScreen(),
          AdminShellScreen.routeName: (_) => const AdminShellScreen(),
          AdminUsersScreen.routeName: (_) => const AdminUsersScreen(),
          AdminCardsScreen.routeName: (_) => const AdminCardsScreen(),
          InstructorGenerateScreen.routeName: (_) =>
              const InstructorGenerateScreen(),
          SubscriptionsScreen.routeName: (_) => const SubscriptionsScreen(),
          ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
          '/onBoarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forget_password': (_) => const ForgotPasswordScreen(),
          '/otp_verify_screen': (_) => const OtpVerifyScreen(),
          '/reset_password_screen': (_) => const ResetPasswordScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/ai': (_) => const FaltaChatAIScreen(),
          '/account': (_) => const ProfileScreen(),
          '/edit-profile': (_) => const EditProfileScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/history': (_) => const HistorySubjectsScreen(),
          '/history-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final subjectId = args is String ? args : 'math';
            return HistoryDetailScreen(initialSubjectId: subjectId);
          },
          AboutScreen.routeName: (_) => const AboutScreen(),
          SupportScreen.routeName: (_) => const SupportScreen(),
          PrivacyScreen.routeName: (_) => const PrivacyScreen(),
          '/courses': (_) => const CoursesScreen(),
          '/exams': (_) => const ExamsScreen(),
          '/past-exams': (_) => const PastExamsArchiveScreen(),
          '/instructors': (_) => const InstructorsScreen(),
          '/past-exam-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final paperId = args is String ? args : '';
            return PastExamDetailScreen(paperId: paperId);
          },
          '/exam-units': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final title = args is String && args.isNotEmpty ? args : 'الرياضيات';
            return ExamUnitsScreen(subjectTitle: title);
          },
          '/exam-session': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map<String, dynamic>) {
              return ExamSessionScreen(
                subjectTitle: args['subjectTitle'] as String? ?? 'الرياضيات',
                examId: args['examId'] as String? ?? '',
              );
            }
            return const ExamSessionScreen(examId: '');
          },
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
