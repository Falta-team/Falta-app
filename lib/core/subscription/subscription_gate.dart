import 'package:falta_app/core/auth/app_role.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/subscriptions/data/sources/subscription_remote_data_source.dart';
import 'package:falta_app/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ensures the student has an active subscription before premium actions.
/// Instructors/admins always pass.
class SubscriptionGate {
  SubscriptionGate._();

  static bool get bypassesGate {
    final role = SharedPrefController().role;
    return role.isInstructor || role.isAdmin;
  }

  static bool get isActiveLocally =>
      bypassesGate || SharedPrefController().subscriptionActive;

  static Future<bool> refreshAndCheck() async {
    if (bypassesGate) return true;
    try {
      final status = await SubscriptionRemoteDataSource().getStatus();
      await SharedPrefController().setSubscriptionActive(status.active);
      return status.active;
    } catch (_) {
      return SharedPrefController().subscriptionActive;
    }
  }

  /// Returns `true` if allowed. Otherwise shows a dialog and returns `false`.
  static Future<bool> ensureActive(BuildContext context) async {
    if (bypassesGate) return true;
    final ok = await refreshAndCheck();
    if (ok) return true;
    if (!context.mounted) return false;
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اشتراك مطلوب',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'فعّل بطاقة الاشتراك للمتابعة إلى هذا المحتوى.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تفعيل بطاقة'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      await Navigator.of(context).pushNamed(SubscriptionsScreen.routeName);
      return SharedPrefController().subscriptionActive;
    }
    return false;
  }
}
