import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/order.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createOrder(Order order) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newOrder = Order(
      id: id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      garmentId: order.garmentId,
      fabricId: order.fabricId,
      designId: order.designId,
      orderDate: order.orderDate,
      dueDate: order.dueDate,
      trialDate: order.trialDate,
      status: order.status,
      totalAmount: order.totalAmount,
      paidAmount: order.paidAmount,
      measurements: order.measurements,
      notes: order.notes,
      specialInstructions: order.specialInstructions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('orders', newOrder.toMap());
    
    // Log the initial status
    await insertStatusLog(StatusLog(
      orderId: id,
      fromStatus: 'created',
      toStatus: order.status,
      changedAt: DateTime.now(),
      notes: 'Order Initialized',
    ));
    
    return id;
  }

  Future<List<Order>> getAllOrders({String? status}) async {
    final db = await _dbHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (status != null) {
      whereClause = 'o.status = ?';
      whereArgs.add(status);
    }

    final result = await db.rawQuery('''
      SELECT o.*, c.name as customerName, g.name as garmentName
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      JOIN garments g ON o.garment_id = g.id
      ${whereClause.isNotEmpty ? 'WHERE ' + whereClause : ''}
      ORDER BY o.due_date ASC
    ''', whereArgs);

    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<Order?> getOrderById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT o.*, c.name as customerName, g.name as garmentName
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      JOIN garments g ON o.garment_id = g.id
      WHERE o.id = ?
    ''', [id]);

    if (result.isNotEmpty) {
      return Order.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateOrderStatus(String orderId, String newStatus, {String? notes}) async {
    final db = await _dbHelper.database;
    final order = await getOrderById(orderId);
    if (order == null) return 0;
    
    final oldStatus = order.status;
    
    final count = await db.update(
      'orders',
      {'status': newStatus, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
    
    if (count > 0) {
      await insertStatusLog(StatusLog(
        orderId: orderId,
        fromStatus: oldStatus,
        toStatus: newStatus,
        changedAt: DateTime.now(),
        notes: notes,
      ));
    }
    return count;
  }

  // --- Payments ---
  Future<String> addPayment(Payment payment) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final p = Payment(
      id: id,
      orderId: payment.orderId,
      amount: payment.amount,
      date: payment.date,
      method: payment.method,
      notes: payment.notes,
      createdAt: DateTime.now(),
    );
    await db.insert('payments', p.toMap());
    return id;
  }

  Future<List<Payment>> getPaymentsForOrder(String orderId) async {
    final db = await _dbHelper.database;
    final result = await db.query('payments', where: 'order_id = ?', whereArgs: [orderId], orderBy: 'date DESC');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  // --- Status Logs ---
  Future<void> insertStatusLog(StatusLog log) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final l = StatusLog(
      id: id,
      orderId: log.orderId,
      fromStatus: log.fromStatus,
      toStatus: log.toStatus,
      changedAt: log.changedAt,
      notes: log.notes,
    );
    await db.insert('order_status_logs', l.toMap());
  }
}
