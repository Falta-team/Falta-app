import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:falta_app/features/notifications/domain/usecases/delete_notification.dart';
import 'package:falta_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:falta_app/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:falta_app/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Repository ────────────────────────────────────────────────────────────
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
      (ref) => const NotificationsRepositoryImpl(),
);

/// ── Get all notifications ────────────────────────────────────────────────
///
/// `notifications_screen.dart` watches `notificationsListProvider` for the
/// real list (`GET /notifications`), and calls
/// `ref.read(notificationsListProvider.notifier).markRead(id)` /
/// `.markAllRead()` / `.delete(id)` from row taps / swipes.
final notificationsListProvider = AsyncNotifierProvider<NotificationsListNotifier,
    List<NotificationsEntity>>(
  NotificationsListNotifier.new,
);

class NotificationsListNotifier
    extends AsyncNotifier<List<NotificationsEntity>> {
  @override
  Future<List<NotificationsEntity>> build() {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      throw const NotificationsApiException('يجب تسجيل الدخول أولاً');
    }
    return GetNotifications(ref.read(notificationsRepositoryProvider))(token);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = SharedPrefController().accessToken;
      if (token.isEmpty) {
        throw const NotificationsApiException('يجب تسجيل الدخول أولاً');
      }
      return GetNotifications(ref.read(notificationsRepositoryProvider))(
        token,
      );
    });
  }

  Future<void> markRead(String id) async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) return;

    await MarkNotificationRead(ref.read(notificationsRepositoryProvider))(
      id,
      token,
    );

    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData([
      for (final n in current) n.id == id ? n.copyWith(isRead: true) : n,
    ]);
  }

  Future<void> markAllRead() async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) return;

    await MarkAllNotificationsRead(ref.read(notificationsRepositoryProvider))(
      token,
    );

    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);
  }

  Future<void> delete(String id) async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) return;

    await DeleteNotification(ref.read(notificationsRepositoryProvider))(
      id,
      token,
    );

    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.where((n) => n.id != id).toList());
  }
}

/// ── Notification settings toggle ─────────────────────────────────────────
///
/// Enable/disable local notifications for new lessons or replies. Backed by
/// `SharedPrefController` so the choice survives app restarts, and read by
/// `LocalNotificationsService.show()` before it fires anything.
final notificationsEnabledProvider =
NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => SharedPrefController().notificationsEnabled;

  Future<void> toggle(bool value) async {
    state = value;
    await SharedPrefController().setNotificationsEnabled(value);
  }
}
