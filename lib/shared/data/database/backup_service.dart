import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class BackupService {
  Future<String?> exportBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, 'ichito.db'));
      
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Create a temp directory for the zip
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final zipPath = p.join(tempDir.path, 'ichito_backup_$dateStr.zip');

      final archive = Archive();
      
      // Add db file to archive
      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('ichito.db', dbBytes.length, dbBytes));
      
      // Try to find images directory
      final appDocsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocsDir.path, 'app_data', 'images'));
      if (await imagesDir.exists()) {
        final entities = await imagesDir.list(recursive: true).toList();
        for (final entity in entities) {
          if (entity is File) {
            final relPath = p.relative(entity.path, from: appDocsDir.path);
            final fileBytes = await entity.readAsBytes();
            archive.addFile(ArchiveFile(relPath, fileBytes.length, fileBytes));
          }
        }
      }
      
      // Create the zip file
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);
      
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes!);

      // Share the file
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        text: 'ICHITO Backup $dateStr',
      );

      return zipFile.path;
    } catch (e) {
      print('Backup error: $e');
      return null;
    }
  }

  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        return false; // User canceled
      }

      final zipFile = File(result.files.single.path!);
      final bytes = await zipFile.readAsBytes();
      
      final archive = ZipDecoder().decodeBytes(bytes);
      
      ArchiveFile? dbArchiveFile;
      for (final file in archive) {
        if (file.name == 'ichito.db') {
          dbArchiveFile = file;
          break;
        }
      }

      if (dbArchiveFile == null) {
        throw Exception('Invalid backup format: ichito.db not found in zip');
      }

      // Close the existing database
      await DatabaseHelper.instance.close();

      // Overwrite the database file
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, 'ichito.db'));
      
      final content = dbArchiveFile.content as List<int>;
      await dbFile.writeAsBytes(content, flush: true);

      // Restore images if present
      final appDocsDir = await getApplicationDocumentsDirectory();
      for (final file in archive) {
        if (file.name != 'ichito.db' && file.isFile) {
          final targetPath = p.join(appDocsDir.path, file.name);
          final targetFile = File(targetPath);
          await targetFile.parent.create(recursive: true);
          await targetFile.writeAsBytes(file.content as List<int>, flush: true);
        }
      }

      // Re-initialize database is done lazily when get database is called
      return true;
    } catch (e) {
      print('Restore error: $e');
      return false;
    }
  }
}
