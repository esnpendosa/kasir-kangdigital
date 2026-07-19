import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileHelper {
  LocalFileHelper._();

  /// Salin file ke folder permanen (Application Documents Directory)
  /// dan kembalikan relative path untuk disimpan di DB/Settings.
  static Future<String> saveImagePermanently(String sourcePath, String folderName) async {
    final file = File(sourcePath);
    if (!await file.exists()) return sourcePath;

    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, folderName));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // Beri nama unik agar tidak bentrok
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}';
    final targetPath = p.join(targetDir.path, filename);
    await file.copy(targetPath);

    // Kembalikan relative path (misal: "product_images/1700000000000_pic.png")
    // Menggunakan pemisah '/' universal agar konsisten
    return '$folderName/$filename';
  }

  /// Dapatkan file secara dinamis. Jika relative path, gabungkan dengan current AppDocDir.
  /// Jika absolute path lama, lakukan validasi & fallback pencarian file di dokumen.
  static Future<File> getFile(String storedPath) async {
    if (storedPath.isEmpty) return File('');

    final appDir = await getApplicationDocumentsDirectory();

    // Normalisasi separator path
    final normalizedStoredPath = storedPath.replaceAll('\\', '/');

    // Cek apakah absolute path
    final isAbsolute = p.isAbsolute(normalizedStoredPath) || 
                       normalizedStoredPath.startsWith('/') || 
                       normalizedStoredPath.contains(':/');

    if (!isAbsolute) {
      return File(p.join(appDir.path, normalizedStoredPath));
    }

    // Kasus absolute path (kemungkinan data lama dari database)
    final file = File(normalizedStoredPath);
    if (await file.exists()) {
      return file;
    }

    // Fallback: jika sandbox path berubah pada update (terutama iOS atau path android baru)
    // Ekstrak nama file dan folder induknya, coba cari secara relatif di AppDocDir
    final filename = p.basename(normalizedStoredPath);
    final parentDir = p.basename(p.dirname(normalizedStoredPath));

    final possiblePaths = [
      p.join(appDir.path, parentDir, filename),
      p.join(appDir.path, filename),
    ];

    for (final path in possiblePaths) {
      final f = File(path);
      if (await f.exists()) {
        return f;
      }
    }

    return file;
  }
}
