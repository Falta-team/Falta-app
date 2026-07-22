import 'package:falta_app/core/navigation/role_home.dart';
import 'package:falta_app/features/auth/domain/bloc/auth_bloc.dart';
import 'package:falta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:falta_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO USE
//  1. No extra packages needed — uses CustomPainter only
//  2. In main.dart → home: SplashScreen(isFirstTime: isFirstTime)
//  3. After the animation it decides on its own where to go next:
//     OnboardingScreen (isFirstTime == true) or LoginScreen (false).
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  final bool isFirstTime;

  const SplashScreen({super.key, required this.isFirstTime});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Stage 1: stroke draws along the path
  late AnimationController _drawController;

  // Stage 2: fill fades in, stroke fades out
  late AnimationController _fillController;

  // Stage 3: red dots scale + fade in
  late AnimationController _dotsController;

  // Stage 4: app name fades in
  late AnimationController _nameController;

  late Animation<double> _drawAnim;
  late Animation<double> _fillAnim;
  late Animation<double> _strokeFadeAnim;
  late Animation<double> _dotsAnim;
  late Animation<double> _dotsScaleAnim;
  late Animation<double> _nameAnim;

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _drawAnim = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOut,
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fillAnim = CurvedAnimation(parent: _fillController, curve: Curves.easeIn);
    _strokeFadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fillController, curve: Curves.easeIn));

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dotsAnim = CurvedAnimation(parent: _dotsController, curve: Curves.easeOut);
    _dotsScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.elasticOut),
    );

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _nameAnim = CurvedAnimation(parent: _nameController, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    // الأنيميشن كما هو
    await _drawController.forward();
    await _fillController.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    await _dotsController.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    await _nameController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // ✅ اسأل AuthBloc إذا في session محفوظة
    final authBloc = context.read<AuthBloc>();
    authBloc.add(const CheckAuthEvent());

    // انتظر أول state مناسب
    await for (final state in authBloc.stream) {
      if (!mounted) return;

      if (state is AlreadyAuthenticatedState) {
        // ✅ في توكن صالح → الشاشة حسب الرول
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => roleHomeScreen()),
              (route) => false,
        );
        return;
      }

      if (state is NotAuthenticatedState) {
        // ✅ ما في توكن → Onboarding أو Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => widget.isFirstTime
                ? const OnboardingScreen()
                : const LoginScreen(),
          ),
        );
        return;
      }
      // AuthLoadingState → استنى الـ state الجاي
    }
  }
  @override
  void dispose() {
    _drawController.dispose();
    _fillController.dispose();
    _dotsController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated Logo ──────────────────────────────────────
            SizedBox(
              width: 240,
              height: 180,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _drawController,
                  _fillController,
                  _dotsController,
                ]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: FaltaLogoPainter(
                      drawProgress: _drawAnim.value,
                      fillOpacity: _fillAnim.value,
                      strokeOpacity: _strokeFadeAnim.value,
                      dotsScale: _dotsScaleAnim.value,
                      dotsOpacity: _dotsAnim.value,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── App Name ───────────────────────────────────────────
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class FaltaLogoPainter extends CustomPainter {
  final double drawProgress; // 0→1  stroke draws along path
  final double fillOpacity; // 0→1  fill fades in
  final double strokeOpacity; // 1→0  stroke fades out
  final double dotsScale; // 0→1  red dots scale (elastic)
  final double dotsOpacity; // 0→1  red dots opacity

  const FaltaLogoPainter({
    required this.drawProgress,
    required this.fillOpacity,
    required this.strokeOpacity,
    required this.dotsScale,
    required this.dotsOpacity,
  });

  // Original SVG canvas size
  static const double _svgW = 678;
  static const double _svgH = 507;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Scale to fit widget ──────────────────────────────────────
    final double scale = (size.width / _svgW) < (size.height / _svgH)
        ? size.width / _svgW
        : size.height / _svgH;
    final double dx = (size.width - _svgW * scale) / 2;
    final double dy = (size.height - _svgH * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // ── Paints ───────────────────────────────────────────────────
    final fillPaint = Paint()
      ..color = const Color(0xFF44AE02).withOpacity(fillOpacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF44AE02).withOpacity(strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = const Color(0xFFF65623).withOpacity(dotsOpacity)
      ..style = PaintingStyle.fill;

    // ── Green paths ──────────────────────────────────────────────
    final paths = [_path1(), _path2()];

    for (final path in paths) {
      // Animated stroke (draws progressively)
      if (strokeOpacity > 0.01) {
        for (final metric in path.computeMetrics()) {
          final length = metric.length * drawProgress;
          if (length > 0) {
            canvas.drawPath(metric.extractPath(0, length), strokePaint);
          }
        }
      }
      // Fill (fades in after stroke completes)
      if (fillOpacity > 0.01) {
        canvas.drawPath(path, fillPaint);
      }
    }

    // ── Red dots ─────────────────────────────────────────────────
    if (dotsOpacity > 0.01) {
      _drawDots(canvas, dotPaint);
    }

    canvas.restore();
  }

  void _drawDots(Canvas canvas, Paint paint) {
    // (cx, cy, rx, ry) from original SVG shapes
    const dots = [
      // Two main eye circles
      [196.249, 313.187, 31.246, 30.879],
      [123.534, 313.187, 31.246, 30.879],
      // Small oval dots (upper right area)
      [435.283, 117.771, 12.0, 23.0],
      [475.783, 98.358, 12.0, 23.0],
      // Round dot (far right)
      [587.884, 230.361, 17.0, 24.5],
    ];

    for (final d in dots) {
      final cx = d[0];
      final cy = d[1];
      final rx = d[2];
      final ry = d[3];
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(dotsScale);
      canvas.translate(-cx, -cy);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        paint,
      );
      canvas.restore();
    }
  }

  // ── Path 1 — ل shape (left curl) ────────────────────────────
  Path _path1() {
    return Path()
      ..moveTo(298.698, 351.287)
      ..cubicTo(288.194, 346.55, 275.783, 351.131, 271.002, 361.536)
      ..cubicTo(269.8, 364.151, 240.771, 425.83, 182.218, 435.097)
      ..cubicTo(122.463, 444.544, 60.4348, 398.757, 41.0215, 330.839)
      ..cubicTo(37.8862, 319.839, 26.3375, 313.42, 15.2069, 316.551)
      ..cubicTo(4.10243, 319.657, -2.35123, 331.098, 0.784151, 342.124)
      ..cubicTo(23.5679, 421.896, 93.8266, 477.726, 166.776, 477.726)
      ..cubicTo(174.092, 477.726, 181.46, 477.157, 188.803, 475.992)
      ..cubicTo(267.866, 463.49, 305.047, 387.368, 309.044, 378.723)
      ..cubicTo(313.826, 368.318, 309.201, 356.049, 298.698, 351.287)
      ..close();
  }

  // ── Path 2 — ف + ت shapes (main body) ──────────────────────
  Path _path2() {
    final p = Path();
    p.moveTo(656.653, 321.21);
    p.cubicTo(629.167, 286.061, 575.708, 263.413, 537.326, 288.054);
    p.cubicTo(509.29, 306.043, 496.2, 347.197, 508.141, 379.784);
    p.cubicTo(520.682, 414.053, 563.898, 440.946, 617.827, 435.381);
    p.cubicTo(598.806, 456.398, 570.039, 461.523, 558.072, 463.646);
    p.cubicTo(518.775, 470.634, 473.234, 457.33, 452.645, 434.864);
    p.cubicTo(452.253, 434.372, 451.835, 433.906, 451.39, 433.44);
    p.cubicTo(448.699, 430.282, 446.478, 426.969, 444.832, 423.501);
    p.cubicTo(442.873, 419.334, 438.901, 405.719, 432.918, 385.116);
    p.lineTo(432.369, 383.511);
    p.cubicTo(432.16, 382.968, 422.284, 356.386, 412.198, 301.72);
    p.cubicTo(433.858, 299.443, 454.526, 292.687, 473.364, 281.583);
    p.cubicTo(536.673, 244.208, 565.1, 166.869, 544.067, 89.1417);
    p.cubicTo(541.089, 78.0896, 529.618, 71.5411, 518.461, 74.4918);
    p.cubicTo(507.305, 77.4425, 500.694, 88.8052, 503.673, 99.8574);
    p.cubicTo(519.794, 159.492, 499.022, 218.221, 451.965, 245.994);
    p.cubicTo(437.49, 254.535, 421.84, 259.453, 405.509, 260.851);
    p.cubicTo(397.096, 202.64, 390.094, 123.075, 390.616, 20.836);
    p.cubicTo(390.669, 9.39559, 381.367, 0.07765, 369.818, 0.02588);
    p.cubicTo(369.792, 0.02588, 369.74, 0.02588, 369.714, 0.02588);
    p.cubicTo(358.217, 0.02588, 348.863, 9.24029, 348.811, 20.6289);
    p.cubicTo(348.315, 119.684, 354.586, 197.903, 362.555, 256.865);
    p.cubicTo(333.997, 249.333, 304.707, 232.328, 276.959, 206.289);
    p.cubicTo(228.125, 160.476, 179.788, 141.892, 133.28, 151.003);
    p.cubicTo(57.0379, 165.937, 17.8456, 250.627, 16.1996, 254.225);
    p.cubicTo(11.4704, 264.63, 16.1734, 276.847, 26.677, 281.557);
    p.cubicTo(37.1805, 286.268, 49.5652, 281.635, 54.3206, 271.23);
    p.cubicTo(54.6341, 270.531, 86.5366, 202.251, 141.563, 191.587);
    p.cubicTo(173.961, 185.324, 209.862, 200.362, 248.218, 236.339);
    p.cubicTo(285.842, 271.618, 325.818, 293.075, 366.996, 300.116);
    p.cubicTo(367.78, 300.245, 368.538, 300.349, 369.322, 300.452);
    p.cubicTo(379.773, 359.983, 390.747, 391.328, 392.968, 397.307);
    p.cubicTo(400.284, 422.414, 403.654, 433.958, 406.946, 440.998);
    p.cubicTo(407.495, 442.163, 408.07, 443.301, 408.671, 444.44);
    p.cubicTo(403.184, 448.504, 397.279, 451.998, 391.034, 454.845);
    p.cubicTo(371.673, 463.646, 353.331, 464.344, 341.339, 463.387);
    p.cubicTo(329.842, 462.481, 319.757, 470.945, 318.816, 482.359);
    p.cubicTo(317.875, 493.774, 326.446, 503.739, 337.968, 504.671);
    p.cubicTo(341.835, 504.981, 345.728, 505.136, 349.595, 505.136);
    p.cubicTo(369.975, 505.136, 390.12, 500.84, 408.462, 492.505);
    p.cubicTo(418.391, 488.002, 427.666, 482.385, 436.21, 475.759);
    p.cubicTo(461.868, 495.275, 498.264, 507.026, 535.497, 507.026);
    p.cubicTo(545.478, 507.026, 555.511, 506.172, 565.44, 504.412);
    p.cubicTo(583.129, 501.28, 636.927, 491.703, 663.786, 442.033);
    p.cubicTo(681.58, 409.162, 686.257, 359.052, 656.653, 321.21);
    p.close();
    // Inner loop (ف circle area)
    p.moveTo(636.064, 389.335);
    p.cubicTo(593.92, 402.975, 555.537, 387.834, 547.438, 365.652);
    p.cubicTo(542.578, 352.374, 546.941, 331.201, 560.058, 322.789);
    p.cubicTo(564.003, 320.253, 568.706, 319.14, 573.827, 319.14);
    p.cubicTo(590.601, 319.14, 611.713, 331.331, 623.627, 346.576);
    p.cubicTo(633.478, 359.181, 636.848, 374.607, 636.064, 389.335);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(FaltaLogoPainter old) =>
      old.drawProgress != drawProgress ||
      old.fillOpacity != fillOpacity ||
      old.strokeOpacity != strokeOpacity ||
      old.dotsScale != dotsScale ||
      old.dotsOpacity != dotsOpacity;
}
