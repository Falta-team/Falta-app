import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles one-time onboarding logic using SharedPreferences.
/// Usage:
///   final service = OnboardingService();
///   final isFirst = await service.isFirstLaunch();   // check
///   await service.completeOnboarding();              // mark done
class OnboardingService {
  static const String _keyOnboardingDone = 'onboarding_done';

  /// Returns true if the user is opening the app for the FIRST time.
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_keyOnboardingDone) ?? false);
  }

  /// Call this when the user finishes the onboarding slides.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  /// Returns true if the user already has a saved access token.
  Future<bool> isAuthenticated() async {
    return SharedPrefController().accessToken.isNotEmpty;
  }

  /// Convenience: determine where to go on app start.
  Future<LaunchDestination> getLaunchDestination() async {
    if (await isFirstLaunch()) return LaunchDestination.onboarding;
    if (await isAuthenticated()) return LaunchDestination.home;
    return LaunchDestination.login;
  }
}

enum LaunchDestination { onboarding, login, home }