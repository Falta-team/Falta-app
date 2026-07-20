// NOTE(falta_app): this service wraps the `flutter_local_notifications`
// package. It wasn't present in the project archive this was written
// against, so add it to `pubspec.yaml` before building:
//
//   dependencies:
//     flutter_local_notifications: ^18.0.0
//
// Android also needs a notification icon at
// `android/app/src/main/res/drawable/ic_notification.png` (or swap the
// `@mipmap/ic_launcher` reference below for your own).

import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around `flutter_local_notifications` used to show local
/// push notifications for new lessons / comment replies.
///
/// This is a device-local notification service (no Firebase Cloud
/// Messaging wiring) — it's meant to be triggered from app code (e.g.
/// after polling `GET /notifications` and finding something unseen), not
/// from a server-sent push. Swap in `firebase_messaging` instead if the
/// backend starts sending real push payloads.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService _instance =
  LocalNotificationsService._();
  factory LocalNotificationsService() => _instance;

  static const String _channelId = 'falta_notifications';
  static const String _channelName = 'إشعارات فلتة';
  static const String _channelDescription =
      'إشعارات الدروس الجديدة وردود التعليقات';

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Call once from `main()`, after `SharedPrefController().initPreferences()`.
  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize( settings: initSettings);
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Shows a local notification, unless the user has turned notifications
  /// off from the app's settings toggle.
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!SharedPrefController().notificationsEnabled) return;
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id: id,title: title,body: body, notificationDetails: details, );
  }
}
