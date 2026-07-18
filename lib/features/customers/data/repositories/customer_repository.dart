import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newCustomer = Customer(
      id: id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      gender: customer.gender,
      location: customer.location,
      photoPath: customer.photoPath,
      measurements: customer.measurements,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('customers', newCustomer.toMap());
    return id;
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    // We join with orders to calculate totalSpent and totalOrders dynamically
    final result = await db.rawQuery('''
      SELECT c.*, 
             COUNT(o.id) as totalOrders,
             COALESCE(SUM(o.total_amount), 0) as totalSpent,
             MAX(o.order_date) as lastOrderDate
      FROM customers c
      LEFT JOIN orders o ON c.id = o.customer_id
      GROUP BY c.id
      ORDER BY c.name ASC
    ''');

    return result.map((map) {
      final customer = Customer.fromMap(map);
      customer.totalOrders = map['totalOrders'] as int;
      customer.totalSpent = (map['totalSpent'] as num).toDouble();
      if (map['lastOrderDate'] != null) {
        customer.lastOrderDate = DateTime.parse(map['lastOrderDate'] as String);
      }
      return customer;
    }).toList();
  }

  Future<List<Customer>> getAll() async {
    return getAllCustomers();
  }

  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  Future<Customer?> getById(String id) async {
    return getCustomerById(id);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    final map = customer.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.update(
      'customers',
      map,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
