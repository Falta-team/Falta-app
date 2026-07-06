import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



// ── Data model لكل tab ────────────────────────────────────────────────────────
class FaltaBottomNavigationData {
  final String title;
  final Widget screen;
  final Widget icon;
  final Widget selectedIcon;

  /// لو true بيخفي الـ AppBar لما هاد الـ tab يكون active
  final bool hideAppBar;

  const FaltaBottomNavigationData({
    required this.title,
    required this.screen,
    required this.icon,
    required this.selectedIcon,
    this.hideAppBar = false,
  });
}

// ── Main Widget ───────────────────────────────────────────────────────────────
class FaltaBottomNavigationScreen extends StatefulWidget {
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
  State<FaltaBottomNavigationScreen> createState() =>
      _FaltaBottomNavigationScreenState();
}

class _FaltaBottomNavigationScreenState
    extends State<FaltaBottomNavigationScreen> {

  late int _selectedPageIndex;
  String _name = '';
  String _image = '';

  // ── هل الصفحة الحالية تخفي الـ AppBar؟ ──────────────────────────────────
  bool get _shouldHideAppBar => widget.pages[_selectedPageIndex].hideAppBar;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex ?? 0;
    _getProfile();
  }

  Future<void> _getProfile() async {
    // TODO: استبدل بـ API call حقيقي
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _name = 'دينا أسعد';
        _image = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F9FF),

        // ── AppBar — مخفي لما hideAppBar = true ────────────────────────────
        appBar: _shouldHideAppBar
            ? null
            : AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                centerTitle: false,
                toolbarHeight: 72,
                // Avatar (يسار)
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: AppColors.bgLight,
                    child: _image.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                        : ClipOval(
                            child: Image.network(
                              'https://falta.app/$_image',
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

                // Name + subtitle
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'مرحباً' : 'مرحبا $_name',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'اهلا بعودتك مرة ثانيه',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),

                // Notification button
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                      child: Container(
                        width: 24,
                        height: 24,
                        child:  Image.asset(
                          'icon_notification.png'.icon_,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

        // ── Body ───────────────────────────────────────────────────────────
        body: IndexedStack(
          index: _selectedPageIndex,
          children: widget.pages.map((p) => p.screen).toList(),
        ),

        // ── FAB ────────────────────────────────────────────────────────────
        floatingActionButton: widget.fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // ── Bottom Nav ──────────────────────────────────────────────────────
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
    final List<Widget> items = [];
    final int total = widget.pages.length;
    final int midIndex = total ~/ 2;

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
