import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/database/database_helper.dart';
import '../models/note.dart';
import '../../../../features/notifications/data/services/notification_service.dart';

class NoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createNote(Note note) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newNote = Note(
      id: id,
      title: note.title,
      content: note.content,
      type: note.type,
      speaker: note.speaker,
      bibleVerses: note.bibleVerses,
      meetingDate: note.meetingDate,
      members: note.members,
      contributions: note.contributions,
      totalCollected: note.totalCollected,
      expectedTotal: note.expectedTotal,
      recipient: note.recipient,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('notes', newNote.toMap());
    await NotificationService().showModelNotification(action: 'Created', type: 'Note', name: note.title, referenceId: note.id);
    return id;
  }

  Future<List<Note>> getAllNotes({String? type}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> result;
    if (type != null) {
      result = await db.query('notes', where: 'type = ?', whereArgs: [type], orderBy: 'updated_at DESC');
    } else {
      result = await db.query('notes', orderBy: 'updated_at DESC');
    }
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Note.fromMap(result.first) : null;
  }

  Future<int> updateNote(Note note) async {
    final db = await _dbHelper.database;
    final res = await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
    await NotificationService().showModelNotification(action: 'Updated', type: 'Note', name: note.title, referenceId: note.id);
    return res;
  }

  Future<int> deleteNote(String id) async {
    final db = await _dbHelper.database;
    final note = await getById(id);
    final res = await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    if (note != null) {
      await NotificationService().showModelNotification(action: 'Deleted', type: 'Note', name: note.title, referenceId: note.id);
    }
    return res;
  }
}
