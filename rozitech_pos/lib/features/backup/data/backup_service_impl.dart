import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/database/app_database.dart' as appdb;

class BackupRecord {
  const BackupRecord({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final String filename;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;
  final String? notes;
}

class BackupServiceImpl {
  const BackupServiceImpl(this._db);
  final appdb.AppDatabase _db;

  /// Helper to locate the active Drift database file.
  Future<File> _getDatabaseFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    
    // 1. Try .sqlite first (default for driftDatabase(name: 'kasirkita_pos'))
    final sqliteFile = File(p.join(docsDir.path, 'kasirkita_pos.sqlite'));
    if (await sqliteFile.exists()) {
      return sqliteFile;
    }
    
    // 2. Try .db fallback (AppConfig.dbName config)
    final dbFile = File(p.join(docsDir.path, 'kasirkita_pos.db'));
    if (await dbFile.exists()) {
      return dbFile;
    }

    // 3. Check application support directory just in case
    final supportDir = await getApplicationSupportDirectory();
    final supportSqlite = File(p.join(supportDir.path, 'kasirkita_pos.sqlite'));
    if (await supportSqlite.exists()) {
      return supportSqlite;
    }
    final supportDb = File(p.join(supportDir.path, 'kasirkita_pos.db'));
    if (await supportDb.exists()) {
      return supportDb;
    }

    // Default to the .sqlite path under documents directory
    return sqliteFile;
  }

  /// Create a backup by copying the SQLite file.
  Future<BackupRecord?> createBackup({String? notes}) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(docsDir.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final dbFile = await _getDatabaseFile();
      if (!await dbFile.exists()) {
        throw Exception('Database file not found at ${dbFile.path}');
      }

      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final filename = 'backup_${timestamp}_kasirkita.db';
      final destPath = p.join(backupDir.path, filename);

      await dbFile.copy(destPath);
      final size = await File(destPath).length();

      // Record backup in DB
      final id = await _db.into(_db.backups).insert(
            appdb.BackupsCompanion.insert(
              filename: filename,
              filePath: destPath,
              fileSize: Value(size),
              notes: Value(notes),
            ),
          );

      return BackupRecord(
        id: id,
        filename: filename,
        filePath: destPath,
        fileSize: size,
        createdAt: DateTime.now(),
        notes: notes,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all recorded backups.
  Future<List<BackupRecord>> getBackups() async {
    final rows = await (_db.select(_db.backups)
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .get();
    return rows
        .map((row) => BackupRecord(
              id: row.id,
              filename: row.filename,
              filePath: row.filePath,
              fileSize: row.fileSize ?? 0,
              createdAt: row.createdAt,
              notes: row.notes,
            ))
        .toList();
  }

  /// Delete a backup record and its file.
  Future<void> deleteBackup(BackupRecord backup) async {
    final file = File(backup.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await (_db.delete(_db.backups)
          ..where((b) => b.id.equals(backup.id)))
        .go();
  }

  /// Restore database from a backup file.
  Future<void> restoreBackup(BackupRecord backup) async {
    await restoreFromPath(backup.filePath);
  }

  /// Restore database from an external file path.
  Future<void> restoreFromPath(String filePath) async {
    try {
      final dbFile = await _getDatabaseFile();
      final backupFile = File(filePath);

      if (!await backupFile.exists()) {
        throw Exception('File backup tidak ditemukan: $filePath');
      }

      // Close the database to release file locks
      await _db.close();

      // Delete WAL and SHM files of the live database if they exist to prevent recovery issues
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (await walFile.exists()) {
        await walFile.delete();
      }
      if (await shmFile.exists()) {
        await shmFile.delete();
      }

      // Copy backup file over the live database file
      await backupFile.copy(dbFile.path);
    } catch (e) {
      rethrow;
    }
  }

  /// Format file size for display.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
