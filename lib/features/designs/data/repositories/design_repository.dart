import 'package:sqflite/sqflite.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/design.dart';

class DesignRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<String> create(Design design) async {
    final db = await _db;
    await db.insert(
      'designs',
      design.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return design.id;
  }

  Future<List<Design>> readAll() async {
    final db = await _db;
    final maps = await db.query('designs', orderBy: 'name ASC');
    return maps.map((map) => Design.fromMap(map)).toList();
  }

  Future<List<Design>> search(String query) async {
    final db = await _db;
    final maps = await db.query(
      'designs',
      where: 'name LIKE ? OR description LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Design.fromMap(map)).toList();
  }

  Future<List<Design>> getTopDesigns({int limit = 5}) async {
    final db = await _db;
    final maps = await db.query(
      'designs',
      orderBy: 'usage_count DESC, updated_at DESC',
      limit: limit,
    );
    return maps.map((map) => Design.fromMap(map)).toList();
  }

  Future<Design?> read(String id) async {
    final db = await _db;
    final maps = await db.query(
      'designs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Design.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Design design) async {
    final db = await _db;
    return await db.update(
      'designs',
      design.toMap(),
      where: 'id = ?',
      whereArgs: [design.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete(
      'designs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
