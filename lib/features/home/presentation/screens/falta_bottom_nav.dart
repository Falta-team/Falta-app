import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/home/domain/providers/home_provider.dart';
import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FaltaBottomNavigationData {
  final String title;
  final Widget screen;
  final Widget icon;
  final Widget selectedIcon;
  final bool hideAppBar;

  const FaltaBottomNavigationData({
    required this.title,
    required this.screen,
    required this.icon,
    required this.selectedIcon,
    this.hideAppBar = false,
  });
}

class FaltaBottomNavigationScreen extends ConsumerStatefulWidget {
  final List<FaltaBottomNavigationData> pages;
  final int? selectedPageIndex;
  final ValueChanged<int>? onTap;
  final Widget? fab;

  const FaltaBottomNavigationScreen({
    super.key,
    required this.pages,
    this.selectedPageIndex,
    this.onTap,
    this.fab,
  });

  @override
  ConsumerState<FaltaBottomNavigationScreen> createState() =>
      _FaltaBottomNavigationScreenState();
}

class _FaltaBottomNavigationScreenState
    extends ConsumerState<FaltaBottomNavigationScreen>
    with WidgetsBindingObserver {
  late int _selectedPageIndex;

  String get _name => SharedPrefController().fullName;
  String get _image => SharedPrefController().profilePhotoUrl;

  bool get _shouldHideAppBar => widget.pages[_selectedPageIndex].hideAppBar;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex ?? 0;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final pref = SharedPrefController();
      if (!pref.isLoggedIn || pref.accessToken.isEmpty) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }
      ref.invalidate(homeDashboardProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F9FF),
        appBar: _shouldHideAppBar
            ? null
            : AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                centerTitle: false,
                toolbarHeight: 72,
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: AppColors.bgLight,
                    child: _image.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                        : ClipOval(
                            child: Image.network(
                              _image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                  ),
                ),
                leadingWidth: 60,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'مرحباً' : 'مرحباً $_name',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'أهلاً بعودتك مرة ثانية',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset('icon_notification.png'.icon_),
                      ),
                    ),
                  ),
                ],
              ),
        body: IndexedStack(
          index: _selectedPageIndex,
          children: widget.pages.map((p) => p.screen).toList(),
        ),
        floatingActionButton: widget.fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: AppColors.white,
          elevation: 8,
          notchMargin: 8,
          shape: widget.fab != null ? const CircularNotchedRectangle() : null,
          child: SizedBox(height: 60, child: Row(children: _buildNavItems())),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    final items = <Widget>[];
    final total = widget.pages.length;
    final midIndex = total ~/ 2;

    for (int i = 0; i < total; i++) {
      if (i == midIndex && widget.fab != null) {
        items.add(72.ws);
      }
      final isActive = _selectedPageIndex == i;
      items.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedPageIndex = i);
              widget.onTap?.call(i);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isActive ? widget.pages[i].selectedIcon : widget.pages[i].icon,
                2.hs,
                Text(
                  widget.pages[i].title,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Cairo',
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }
}
