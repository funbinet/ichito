import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import '../../../features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Get notifications with optional filtering and pagination.
  Future<List<AppNotification>> getAll({
    String? searchQuery,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _dbHelper.database;
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where += ' AND (title LIKE ? OR body LIKE ? OR client_name LIKE ? OR order_id LIKE ? OR client_id LIKE ?)';
      final likeQuery = '%$searchQuery%';
      whereArgs.addAll([likeQuery, likeQuery, likeQuery, likeQuery, likeQuery]);
    }

    if (type != null && type.isNotEmpty && type != 'All') {
      where += ' AND type = ?';
      whereArgs.add(type);
    }

    final results = await db.query(
      'notifications',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((map) => AppNotification.fromMap(map)).toList();
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Insert a new notification. Returns the generated ID.
  Future<String> insert(AppNotification notification) async {
    final db = await _dbHelper.database;
    final id = notification.id.isNotEmpty ? notification.id : _uuid.v4();
    final n = AppNotification(
      id: id,
      title: notification.title,
      body: notification.body,
      type: notification.type,
      action: notification.action,
      referenceId: notification.referenceId,
      clientId: notification.clientId,
      orderId: notification.orderId,
      clientName: notification.clientName,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
    );
    await db.insert('notifications', n.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return id;
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final db = await _dbHelper.database;
    await db.update('notifications', {'is_read': 1});
  }

  /// Check if a notification with given type and referenceId already exists today.
  /// Used to avoid duplicate due-date notifications on the same day.
  Future<bool> existsForToday(String type, String referenceId) async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE type = ? AND reference_id = ? AND created_at BETWEEN ? AND ?',
      [type, referenceId, startOfDay, endOfDay],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
