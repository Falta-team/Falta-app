import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/history/data/repositories/history_repository_impl.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/usecases/get_history_subjects.dart';
import 'package:falta_app/features/history/presentation/screens/history_detail_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Subject picker before opening per-subject history.
class HistorySubjectsScreen extends StatefulWidget {
  const HistorySubjectsScreen({super.key});

  static const String routeName = '/history';

  @override
  State<HistorySubjectsScreen> createState() => _HistorySubjectsScreenState();
}

class _HistorySubjectsScreenState extends State<HistorySubjectsScreen> {
  late final GetHistorySubjects _getSubjects =
      GetHistorySubjects(HistoryRepositoryImpl());

  bool _loading = true;
  List<HistorySubjectEntity> _subjects = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subjects = await _getSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      _loading = false;
    });
  }

  void _openSubject(HistorySubjectEntity subject) {
    Navigator.of(context).pushNamed(
      HistoryDetailScreen.routeName,
      arguments: subject.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'السجل'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر المادة',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return _SubjectHistoryCard(
                          subject: subject,
                          onTap: () => _openSubject(subject),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SubjectHistoryCard extends StatelessWidget {
  const _SubjectHistoryCard({
    required this.subject,
    required this.onTap,
  });

  final HistorySubjectEntity subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/${subject.image}.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A1A2E)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              right: 14,
              left: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  4.hs,
                  Text(
                    '${subject.correctCount} صحيحة · ${subject.wrongCount} خاطئة',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
