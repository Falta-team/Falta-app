import 'package:falta_app/features/notifications/domain/providers/notifications_provider.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const Color kBg = Color(0xFFF3F9FF);
  static const Color kGreen = Color(0xFF44AE02);
  static const Color kTextDark = Color(0xFF1A202C);
  static const Color kTextGray = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE2E8F0);
  static const Color kWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_forward, color: kTextDark, size: 26),
                    ),
                    const Expanded(
                      child: Text(
                        'الاشعارات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Switch(
                      value: notificationsEnabled,
                      activeThumbColor: kGreen,
                      onChanged: (value) {
                        ref.read(notificationsEnabledProvider.notifier).toggle(value);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: kBorder, height: 1),
              Expanded(
                child: notificationsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: kGreen),
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
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: kTextGray,
                            ),
                          ),
                          12.hs,
                          TextButton(
                            onPressed: () => ref
                                .read(notificationsListProvider.notifier)
                                .refresh(),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(fontFamily: 'Cairo', color: kGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد إشعارات بعد',
                          style: TextStyle(fontFamily: 'Cairo', color: kTextGray),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: kGreen,
                      onRefresh: () =>
                          ref.read(notificationsListProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: kBorder,
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        itemBuilder: (context, i) {
                          final n = notifications[i];
                          return Dismissible(
                            key: ValueKey(n.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red.withValues(alpha: 0.9),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete_outline, color: kWhite),
                            ),
                            onDismissed: (_) =>
                                ref.read(notificationsListProvider.notifier).delete(n.id),
                            child: InkWell(
                              onTap: () {
                                if (!n.isRead) {
                                  ref
                                      .read(notificationsListProvider.notifier)
                                      .markRead(n.id);
                                }
                              },
                              child: Container(
                                color: n.isRead ? null : kGreen.withValues(alpha: 0.05),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: kGreen,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _iconForType(n.type),
                                        color: kWhite,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: kTextDark,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            n.body,
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatRelativeTime(n.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: kTextGray,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        if (!n.isRead) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: kGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_lesson':
        return Icons.play_circle_outline;
      case 'reply':
        return Icons.chat_bubble_outline;
      case 'exam':
        return Icons.assignment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatRelativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
