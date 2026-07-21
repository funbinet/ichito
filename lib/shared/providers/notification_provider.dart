import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/database/notification_repository.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/orders/data/repositories/order_repository.dart';

/// Provider that manages notification state.
/// 
/// Handles loading notifications from SQLite, checking for due orders,
/// and maintaining the unread count for the badge.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  final OrderRepository _orderRepo = OrderRepository();
  final Uuid _uuid = const Uuid();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  
  String? _searchQuery;
  String? _filterType;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  /// Load initial notifications from SQLite. Call during app startup.
  Future<void> loadNotifications({String? query, String? type}) async {
    _searchQuery = query;
    _filterType = type;
    _isLoading = true;
    notifyListeners();

    _notifications = await _repo.getAll(searchQuery: _searchQuery, type: _filterType, limit: 20, offset: 0);
    _unreadCount = await _repo.getUnreadCount();
    _hasMore = _notifications.length == 20;
    _isLoading = false;
    notifyListeners();
  }

  /// Load more notifications for pagination.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();

    final more = await _repo.getAll(searchQuery: _searchQuery, type: _filterType, limit: 20, offset: _notifications.length);
    _notifications.addAll(more);
    _hasMore = more.length == 20;
    _isLoading = false;
    notifyListeners();
  }

  /// Check for orders with due dates within the next 5 days and generate
  /// notifications for them. Avoids duplicates for the same order on the same day.
  Future<void> checkOrderDueDates() async {
    try {
      final orders = await _orderRepo.getAllOrders();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var order in orders) {
        // Skip completed/cancelled orders
        if (order.status == 'completed' || order.status == 'cancelled') continue;

        final dueDate = DateTime(
          order.dueDate.year,
          order.dueDate.month,
          order.dueDate.day,
        );
        final daysRemaining = dueDate.difference(today).inDays;

        // Generate notifications for orders due within 5 days (including overdue)
        if (daysRemaining <= 5) {
          // Check if we already notified about this order today
          final exists = await _repo.existsForToday('order_due', order.id ?? '');
          if (exists) continue;

          String title;
          String body;
          if (daysRemaining < 0) {
            title = '⚠️ Order Overdue!';
            body = 'Order ${order.orderNumber}${order.customerName != null ? ' for ${order.customerName}' : ''} is ${-daysRemaining} day${daysRemaining == -1 ? '' : 's'} overdue.';
          } else if (daysRemaining == 0) {
            title = '🔴 Order Due Today!';
            body = 'Order ${order.orderNumber}${order.customerName != null ? ' for ${order.customerName}' : ''} is due today!';
          } else {
            title = '📋 Order Due Soon';
            body = 'Order ${order.orderNumber}${order.customerName != null ? ' for ${order.customerName}' : ''} has $daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining.';
          }

          final notification = AppNotification(
            id: _uuid.v4(),
            title: title,
            body: body,
            type: 'System',
            action: 'System',
            referenceId: order.id,
            orderId: order.id,
            clientId: order.customerId,
            clientName: order.customerName,
            createdAt: DateTime.now(),
          );

          await _repo.insert(notification);
        }
      }

      // Reload after generating new notifications
      await loadNotifications(query: _searchQuery, type: _filterType);
    } catch (e) {
      // Silently handle - orders table might be empty or have join issues
      debugPrint('NotificationProvider.checkOrderDueDates error: $e');
    }
  }

  /// Add a custom notification (e.g., order fully paid, order updated).
  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    required String action,
    String? referenceId,
    String? clientId,
    String? orderId,
    String? clientName,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
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
    await _repo.insert(notification);
    await loadNotifications(query: _searchQuery, type: _filterType);
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    // Update local state
    _notifications = _notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    _unreadCount = await _repo.getUnreadCount();
    notifyListeners();
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }
}
