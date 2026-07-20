import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:falta_app/features/profile/domain/usecases/get_settings.dart';
import 'package:falta_app/features/profile/domain/usecases/save_settings.dart';
import 'package:falta_app/features/profile/presentation/widgets/difficulty_bottom_sheet.dart';
import 'package:falta_app/features/profile/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "الإعدادات" screen (Figma nodes 1:25054 and 1:25129).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ProfileRepositoryImpl _repository = ProfileRepositoryImpl();
  late final GetSettings _getSettings = GetSettings(_repository);
  late final SaveSettings _saveSettings = SaveSettings(_repository);

  AppSettingsEntity? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _getSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _update(AppSettingsEntity updated) async {
    setState(() => _settings = updated);
    await _saveSettings(updated);
  }

  Future<void> _pickDifficulty() async {
    final settings = _settings;
    if (settings == null) return;
    final picked = await showDifficultyBottomSheet(
      context,
      current: settings.difficulty,
    );
    if (picked != null && picked != settings.difficulty) {
      await _update(settings.copyWith(difficulty: picked));
    }
  }

  Widget _switch({required bool value, required ValueChanged<bool> onChanged}) {
    return Transform.scale(
      scale: 0.75,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.white,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: AppColors.white,
        inactiveTrackColor: const Color(0xFFD9D9D9),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'الإعدادات'),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsTile(
                  iconAsset: 'assets/icons/profile/ic_speedometer.svg',
                  title: 'صعوبة الاسئلة',
                  subtitle: 'تحديد صعوبة الاسئلة',
                  onTap: _pickDifficulty,
                  trailing: Text(
                    settings.difficulty.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0x80060606),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SettingsTile(
                  iconAsset: 'assets/icons/profile/ic_notification_bold.svg',
                  title: 'تفعيل الاشعارات',
                  subtitle: 'تنبيه وإشعارات التذكير بالاختبارات',
                  trailing: _switch(
                    value: settings.notificationsEnabled,
                    onChanged: (v) =>
                        _update(settings.copyWith(notificationsEnabled: v)),
                  ),
                ),
                const SizedBox(height: 24),
                SettingsTile(
                  iconAsset: 'assets/icons/profile/ic_volume.svg',
                  title: 'الصوت',
                  subtitle: 'الموسيقى والأصوات اثناء استخدام التطبيق',
                  trailing: _switch(
                    value: settings.soundEnabled,
                    onChanged: (v) =>
                        _update(settings.copyWith(soundEnabled: v)),
                  ),
                ),
              ],
            ),
    );
  }
}
