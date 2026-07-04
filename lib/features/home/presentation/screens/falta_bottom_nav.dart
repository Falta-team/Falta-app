import 'package:falta_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
// import 'package:falta/api/controllers/user_api_controller.dart';
// import 'package:falta/model/auth/user_model.dart';

// ── Data model لكل tab ────────────────────────────────────────────────────────
class FaltaBottomNavigationData {
  final String title;
  final Widget screen;
  final Widget icon;
  final Widget selectedIcon;

  const FaltaBottomNavigationData({
    required this.title,
    required this.screen,
    required this.icon,
    required this.selectedIcon,
  });
}

// ── Main Widget ───────────────────────────────────────────────────────────────
class FaltaBottomNavigationScreen extends StatefulWidget {
  final List<FaltaBottomNavigationData> pages;
  final int? selectedPageIndex;
  final ValueChanged<int>? onTap;
  final Widget? fab; // الـ FAB (زر الشات)

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
  // ── Design Tokens ───────────────────────────────────────────────────────────
  static const Color kGreen      = Color(0xFF44AE02);
  static const Color kGreenLight = Color(0xFFE8F5E2);
  static const Color kTextDark   = Color(0xFF1A202C);
  static const Color kTextGray   = Color(0xFF64748B);
  static const Color kBorder     = Color(0xFFE2E8F0);
  static const Color kWhite      = Color(0xFFFFFFFF);

  late int _selectedPageIndex;
  String _name  = '';
  String _image = '';

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex ?? 0;
    _getProfile();
  }

  // ── Fetch user profile ──────────────────────────────────────────────────────
  Future<void> _getProfile() async {
    // TODO: استبدل بـ API call حقيقي
    // UserApiController apiController = UserApiController();
    // UserModel user = await apiController.getUser();
    // setState(() { _name = user.name; _image = user.image; });

    // بيانات تجريبية
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _name  = 'دينا أسعد';
        _image = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FF),

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        centerTitle: false,
        // Avatar (يسار)
        leading: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: kGreenLight,
            child: _image.isEmpty
                ? const Icon(Icons.person, color: kGreen, size: 24)
                : ClipOval(
              child: Image.network(
                'https://falta.app/$_image',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.person, color: kGreen, size: 24),
              ),
            ),
          ),
        ),
        leadingWidth: 60,

        // Name + subtitle (وسط)
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _name.isEmpty ? 'مرحباً' : 'مرحبا $_name',
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
              const Text(
                'اهلا بعودتك مرة ثانيه',
                style: TextStyle(
                  color: kTextGray,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),

        // Notification button (يمين)
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen()),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: kTextDark,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Body: IndexedStack يحافظ على state كل tab ─────────────────────────
      body: IndexedStack(
        index: _selectedPageIndex,
        children: widget.pages.map((p) => p.screen).toList(),
      ),

      // ── FAB (زر الشات) ─────────────────────────────────────────────────────
      floatingActionButton: widget.fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Nav ──────────────────────────────────────────────────────────
      bottomNavigationBar: BottomAppBar(
        color: kWhite,
        elevation: 8,
        notchMargin: 8,
        shape: widget.fab != null
            ? const CircularNotchedRectangle()
            : null,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: 60,
            child: Row(
              children: _buildNavItems(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build nav items مع فراغ للـ FAB في المنتصف ────────────────────────────
  List<Widget> _buildNavItems() {
    final List<Widget> items = [];
    final int total = widget.pages.length;
    final int midIndex = total ~/ 2; // المنتصف للـ FAB

    for (int i = 0; i < total; i++) {
      // فراغ للـ FAB في المنتصف
      if (i == midIndex && widget.fab != null) {
        items.add(const SizedBox(width: 72));
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
                isActive
                    ? widget.pages[i].selectedIcon
                    : widget.pages[i].icon,
                const SizedBox(height: 2),
                Text(
                  widget.pages[i].title,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Cairo',
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isActive ? kGreen : kTextGray,
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