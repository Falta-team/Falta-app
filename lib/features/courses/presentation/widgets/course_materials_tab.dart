import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/course_material_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseMaterialsTab extends StatelessWidget {
  const CourseMaterialsTab({
    super.key,
    required this.materialsAsync,
    required this.onRetry,
  });

  final AsyncValue<List<CourseMaterialEntity>> materialsAsync;
  final VoidCallback onRetry;

  Future<void> _open(BuildContext context, CourseMaterialEntity material) async {
    if (material.fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط للملف')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: material.fileUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ رابط: ${material.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return materialsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
            child: Text(
              'لا توجد مواد لهذا الكورس بعد',
              style: GoogleFonts.cairo(color: AppColors.textSecondaryLight),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: materials.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = materials[i];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.white,
              leading: Icon(
                m.isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: AppColors.primary,
              ),
              title: Text(
                m.title,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
              subtitle: m.description.isEmpty
                  ? null
                  : Text(m.description, style: GoogleFonts.cairo(fontSize: 12)),
              trailing: const Icon(Icons.copy, size: 18),
              onTap: () => _open(context, m),
            );
          },
        );
      },
    );
  }
}
