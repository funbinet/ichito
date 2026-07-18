import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/materials.dart';

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
    return id;
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
    return id;
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
