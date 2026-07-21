import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/notification_repository.dart';
import '../models/notification_model.dart';

/// Service wrapper for local push notifications.
///
/// Handles initialization, permission requests, and displaying
/// notifications when the app is in background or closed.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service. Call once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezones
    tz.initializeTimeZones();
    try {
      final String currentTimeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Could not set timezone: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permission (Android 13+)
    await _requestPermission();

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — navigation is handled by the app
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'ichito_orders',
      'Order Reminders',
      channelDescription: 'Notifications about upcoming order due dates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Show an instant notification for C/U/D operations.
  Future<void> showModelNotification({
    required String action, // Created, Updated, Deleted
    required String type,   // Client, Order, Fabric, etc.
    required String name,   // Name of the item
    String? referenceId,
    String? clientId,
    String? orderId,
    String? clientName,
  }) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final String title = '$type $action';
    final String body = '$name has been successfully ${action.toLowerCase()}.';
    
    // Save to DB
    try {
      final notif = AppNotification(
        id: const Uuid().v4(),
        title: title,
        body: body,
        type: type,
        action: action,
        referenceId: referenceId,
        clientId: clientId,
        orderId: orderId,
        clientName: clientName,
        createdAt: DateTime.now(),
      );
      await NotificationRepository().insert(notif);
    } catch (e) {
      debugPrint('Failed to save notification: $e');
    }

    await showNotification(id: id, title: title, body: body);
  }

  /// Schedule due reminders for an order at 8am, 12pm, and 6pm on the due date.
  Future<void> scheduleDueReminders(DateTime dueDate, String orderNumber, String customerName) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'ichito_due_reminders',
      'Due Reminders',
      channelDescription: 'Scheduled reminders for order due dates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const details = NotificationDetails(android: androidDetails);

    final List<int> reminderHours = [8, 12, 18]; // 8 AM, 12 PM, 6 PM

    for (int hour in reminderHours) {
      final scheduledDate = DateTime(dueDate.year, dueDate.month, dueDate.day, hour, 0);
      
      // Only schedule if it's in the future
      if (scheduledDate.isAfter(DateTime.now())) {
        final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
        final int id = (orderNumber.hashCode + hour).remainder(100000);
        
        await _plugin.zonedSchedule(
          id,
          'Order Due Today',
          'Order $orderNumber for $customerName is due at ${hour == 12 ? 'noon' : hour > 12 ? '${hour-12} PM' : '$hour AM'}.',
          tzScheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  /// Show a summary notification for multiple due orders.
  Future<void> showOrdersDueSummary({
    required int count,
    required String body,
  }) async {
    await showNotification(
      id: 1000, // Fixed ID for summary notification
      title: '📋 $count order${count == 1 ? '.t(context)' : 's'} due soon',
      body: body,
      payload: 'orders_due',
    );
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel a specific notification by ID.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
