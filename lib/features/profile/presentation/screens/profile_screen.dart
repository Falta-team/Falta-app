import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/data/auth_api_controller.dart';
import 'package:falta_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';
import 'package:falta_app/features/profile/domain/usecases/get_profile.dart';
import 'package:falta_app/features/profile/presentation/screens/about_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/privacy_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/support_screen.dart';
import 'package:falta_app/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:falta_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final GetProfile _getProfile = GetProfile(ProfileRepositoryImpl());
  ProfileEntity? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await _getProfile();
    if (!mounted) return;
    setState(() { _profile = profile; _loading = false; });
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
    );
    await _load();
  }

  void _comingSoon() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('قريباً')),
  );

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await showLogoutDialog(context);
    if (confirmed != true || !mounted) return;

    final pref = SharedPrefController();

    // استدعي الـ API logout
    await AuthApiController().logout(
      accessToken:  pref.accessToken,
      refreshToken: pref.refreshToken,
    );

    // امسح كل البيانات المحلية
    await pref.clear();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Avatar ──────────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 39,
                    backgroundColor: AppColors.bgLight,
                    backgroundImage: (profile?.avatarUrl.isNotEmpty == true)
                        ? NetworkImage(profile!.avatarUrl)
                        : null,
                    child: (profile?.avatarUrl.isNotEmpty == true)
                        ? null
                        : const Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  PositionedDirectional(
                    end: -4, bottom: -4,
                    child: GestureDetector(
                      onTap: _openEditProfile,
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.white, shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: SvgPicture.asset('assets/icons/profile/ic_edit.svg'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Name ────────────────────────────────────────────────
              Text(
                profile?.fullName ?? SharedPrefController().fullName,
                style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Opacity(
                opacity: 0.8,
                child: Text(
                  profile?.branch ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Edit button ─────────────────────────────────────────
              SizedBox(
                width: 136, height: 32,
                child: ElevatedButton(
                  onPressed: _openEditProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(136, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تعديل الملف الشخصي',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),

              // ── Menu ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 16, 23, 24),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_settings.svg',
                      label: 'الاعدادات',
                      onTap: () => Navigator.of(context).pushNamed('/settings'),
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_card.svg',
                      iconSize: 24,
                      label: 'البطاقات',
                      onTap: _comingSoon,
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_favorite.svg',
                      label: 'المفضلة',
                      onTap: () => Navigator.of(context).pushNamed('/favorites'),
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_history.svg',
                      iconSize: 24,
                      label: 'السجل',
                      onTap: _comingSoon,
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_about.svg',
                      label: 'حول التطبيق',
                      onTap: () => Navigator.of(context).pushNamed(AboutScreen.routeName),
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_support.svg',
                      label: 'الدعم الفني',
                      onTap: () => Navigator.of(context).pushNamed(SupportScreen.routeName),
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_privacy.svg',
                      iconSize: 20,
                      label: 'سياسة الخصوصية',
                      onTap: () => Navigator.of(context).pushNamed(PrivacyScreen.routeName),
                    ),
                    ProfileMenuItem(
                      iconAsset: 'assets/icons/profile/ic_logout.svg',
                      iconSize: 20,
                      label: 'تسجيل الخروج',
                      showChevron: false,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}