import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/materials.dart';
import '../../../../features/notifications/data/services/notification_service.dart';

class FabricRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createFabric(Fabric fabric) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newFabric = Fabric(
      id: id,
      name: fabric.name,
      description: fabric.description,
      pricePerUnit: fabric.pricePerUnit,
      unit: fabric.unit,
      category: fabric.category,
      color: fabric.color,
      imagePath: fabric.imagePath,
      usageCount: fabric.usageCount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('fabrics', newFabric.toMap());
    await NotificationService().showModelNotification(action: 'Created', type: 'Fabric', name: fabric.name);
    return id;
  }

  Future<int> updateFabric(Fabric fabric) async {
    final db = await _dbHelper.database;
    final res = await db.update('fabrics', fabric.toMap(), where: 'id = ?', whereArgs: [fabric.id]);
    await NotificationService().showModelNotification(action: 'Updated', type: 'Fabric', name: fabric.name);
    return res;
  }

  Future<int> deleteFabric(String id) async {
    final db = await _dbHelper.database;
    final fabric = await getById(id);
    final res = await db.delete('fabrics', where: 'id = ?', whereArgs: [id]);
    if (fabric != null) {
      await NotificationService().showModelNotification(action: 'Deleted', type: 'Fabric', name: fabric.name);
    }
    return res;
  }

  Future<List<Fabric>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('fabrics', orderBy: 'name ASC');
    return result.map((map) => Fabric.fromMap(map)).toList();
  }

  Future<Fabric?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('fabrics', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Fabric.fromMap(result.first);
    }
    return null;
  }
}

class DesignRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createDesign(Design design) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newDesign = Design(
      id: id,
      name: design.name,
      description: design.description,
      category: design.category,
      imagePath: design.imagePath,
      usageCount: design.usageCount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('designs', newDesign.toMap());
    await NotificationService().showModelNotification(action: 'Created', type: 'Design', name: design.name);
    return id;
  }

  Future<int> updateDesign(Design design) async {
    final db = await _dbHelper.database;
    final res = await db.update('designs', design.toMap(), where: 'id = ?', whereArgs: [design.id]);
    await NotificationService().showModelNotification(action: 'Updated', type: 'Design', name: design.name);
    return res;
  }

  Future<int> deleteDesign(String id) async {
    final db = await _dbHelper.database;
    final design = await getById(id);
    final res = await db.delete('designs', where: 'id = ?', whereArgs: [id]);
    if (design != null) {
      await NotificationService().showModelNotification(action: 'Deleted', type: 'Design', name: design.name);
    }
    return res;
  }

  Future<List<Design>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('designs', orderBy: 'name ASC');
    return result.map((map) => Design.fromMap(map)).toList();
  }

  Future<Design?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('designs', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Design.fromMap(result.first);
    }
    return null;
  }
}
