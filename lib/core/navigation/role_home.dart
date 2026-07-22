import 'package:falta_app/core/auth/app_role.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:falta_app/features/home/presentation/screens/home_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_shell_screen.dart';
import 'package:flutter/material.dart';

/// Resolves the correct home widget for the logged-in role.
Widget roleHomeScreen({AppRole? role}) {
  final resolved = role ?? SharedPrefController().role;
  if (resolved.isAdmin) return const AdminShellScreen();
  if (resolved.isInstructor) return const InstructorShellScreen();
  return const HomeScreen();
}

/// Named route used after login / splash for role-aware entry.
String roleHomeRoute({AppRole? role}) {
  final resolved = role ?? SharedPrefController().role;
  if (resolved.isAdmin) return AdminShellScreen.routeName;
  if (resolved.isInstructor) return InstructorShellScreen.routeName;
  return '/home';
}

Future<void> goToRoleHome(BuildContext context, {AppRole? role}) {
  final route = roleHomeRoute(role: role);
  return Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
}
