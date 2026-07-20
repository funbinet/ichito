import 'package:flutter/material.dart';
import '../../features/orders/data/models/order.dart';
import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/notifications/data/services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  List<Order> _orders = [];
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repository.getAllOrders();
      _payments = await _repository.getAllPayments();
    } catch (e) {
      debugPrint('Error loading orders/payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(Order order) async {
    await _repository.createOrder(order);
    await NotificationService().showModelNotification(action: 'Created', type: 'Order', name: order.orderNumber);
    await NotificationService().scheduleDueReminders(order.dueDate, order.orderNumber, order.customerName ?? 'Client');
    await loadOrders();
  }

  Future<void> updateOrder(Order order) async {
    await _repository.updateOrder(order);
    await NotificationService().showModelNotification(action: 'Updated', type: 'Order', name: order.orderNumber);
    await NotificationService().scheduleDueReminders(order.dueDate, order.orderNumber, order.customerName ?? 'Client');
    await loadOrders();
  }

  Future<void> deleteOrder(String id) async {
    final order = getOrderById(id);
    await _repository.deleteOrder(id);
    if (order != null) {
      await NotificationService().showModelNotification(action: 'Deleted', type: 'Order', name: order.orderNumber);
    }
    await loadOrders();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addPayment(Payment payment) async {
    await _repository.addPayment(payment);
    await loadOrders(); // refresh both orders (for paid amounts) and payments
  }
}
