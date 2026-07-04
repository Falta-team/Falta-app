import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color kBg       = Color(0xFFF3F9FF);
  static const Color kGreen    = Color(0xFF44AE02);
  static const Color kTextDark = Color(0xFF1A202C);
  static const Color kTextGray = Color(0xFF64748B);
  static const Color kBorder   = Color(0xFFE2E8F0);
  static const Color kWhite    = Color(0xFFFFFFFF);

  static const List<Map<String, String>> _notifications = [
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
    {'title': 'مرحبا محمد', 'body': 'هذا النص هو مثال لنص يمكن أن يستبدل', 'time': 'منذ 5 ساعات'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الاشعارات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_forward,
                          color: kTextDark, size: 26),
                    ),
                  ],
                ),
              ),

              const Divider(color: kBorder, height: 1),

              // ── List ─────────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) =>
                  const Divider(color: kBorder, height: 1, indent: 20, endIndent: 20),
                  itemBuilder: (context, i) {
                    final n = _notifications[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: kWhite,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n['title']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kTextDark,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n['body']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextGray,
                                    fontFamily: 'Cairo',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Time
                          Text(
                            n['time']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextGray,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}