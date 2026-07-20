import 'package:falta_app/features/exams/presentation/screens/past_exams_archive_screen.dart';
import 'package:flutter/material.dart';

/// تبويب أسئلة الامتحانات — أرشيف السنوات السابقة.
class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  static const String routeName = '/exams';

  @override
  Widget build(BuildContext context) {
    return const PastExamsArchiveScreen();
  }
}
