import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/garment.dart';

class GarmentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createGarment(Garment garment) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newGarment = Garment(
      id: id,
      name: garment.name,
      category: garment.category,
      description: garment.description,
      measurementFields: garment.measurementFields,
      defaultPrice: garment.defaultPrice,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('garments', newGarment.toMap());
    return id;
  }

  Future<List<Garment>> getAllGarments({String? category}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> result;
    if (category != null) {
      result = await db.query('garments', where: 'category = ?', whereArgs: [category], orderBy: 'name ASC');
    } else {
      result = await db.query('garments', orderBy: 'name ASC');
    }
    return result.map((map) => Garment.fromMap(map)).toList();
  }

  Future<List<Garment>> getAll() async {
    return getAllGarments();
  }

  Future<Garment?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('garments', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Garment.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteGarment(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('garments', where: 'id = ?', whereArgs: [id]);
  }
}
