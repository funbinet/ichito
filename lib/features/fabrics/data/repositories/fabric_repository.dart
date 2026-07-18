import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/fabric.dart';

class FabricRepository {
  final _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<String> addFabric(Fabric fabric) async {
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('fabrics', newFabric.toMap());
    return id;
  }

  Future<List<Fabric>> getAllFabrics() async {
    final db = await _dbHelper.database;
    final maps = await db.query('fabrics', orderBy: 'name ASC');
    return maps.map((m) => Fabric.fromMap(m)).toList();
  }

  Future<List<Fabric>> searchFabrics(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fabrics',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC'
    );
    return maps.map((m) => Fabric.fromMap(m)).toList();
  }

  Future<void> updateFabric(Fabric fabric) async {
    final db = await _dbHelper.database;
    await db.update(
      'fabrics',
      fabric.toMap(),
      where: 'id = ?',
      whereArgs: [fabric.id],
    );
  }

  Future<void> deleteFabric(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'fabrics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
