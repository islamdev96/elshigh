import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class BackupManager {
  final DatabaseHelper dbHelper;

  BackupManager(this.dbHelper);

  Future<Directory> get _externalDirectory async {
    final directory = await getExternalStorageDirectory();
    final appDir = Directory('${directory!.path}/MyAppImages');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<String> _encodeImageToBase64(String imagePath) async {
    if (imagePath.isEmpty) return '';
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    }
    return '';
  }

  Future<String?> _decodeImageFromBase64(
      String base64Image, String fileName) async {
    if (base64Image.isEmpty || fileName.isEmpty) return null;
    try {
      final externalDir = await _externalDirectory;
      final String newPath = '${externalDir.path}/$fileName';
      final bytes = base64Decode(base64Image);
      await File(newPath).writeAsBytes(bytes);
      return newPath;
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }

  Future<void> backupToJson(String backupName) async {
    try {
      final data = await dbHelper.getBeneficiaries();
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups/$backupName');
      await backupDir.create(recursive: true);

      final List<Map<String, dynamic>> modifiedData = [];

      for (var item in data) {
        final modifiedItem = Map<String, dynamic>.from(item);
        if (item['image1Path'] != null && item['image1Path'].isNotEmpty) {
          modifiedItem['image1Path'] =
              await _encodeImageToBase64(item['image1Path']);
        }
        if (item['image2Path'] != null && item['image2Path'].isNotEmpty) {
          modifiedItem['image2Path'] =
              await _encodeImageToBase64(item['image2Path']);
        }
        modifiedData.add(modifiedItem);
      }

      final jsonData = json.encode(modifiedData);

      // Compress the JSON data
      final List<int> jsonBytes = utf8.encode(jsonData);
      final List<int> compressedData = GZipEncoder().encode(jsonBytes)!;

      // Save compressed data
      final compressedFile = File('${backupDir.path}/data.gz');
      await compressedFile.writeAsBytes(compressedData);

      // Share the backup file
      await shareBackup(compressedFile.path);
    } catch (e) {
      throw Exception('فشل في إنشاء النسخة الاحتياطية: $e');
    }
  }

  Future<void> shareBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(backupPath)],
            text: 'نسخة احتياطية من التطبيق'); // Create an XFile
      } else {
        // Handle the case where the file doesn't exist.  Perhaps show an error message to the user.
        print('Backup file not found at: $backupPath');
        // Or throw an exception if that's your error handling strategy:
        // throw Exception('Backup file not found');
      }
    } catch (e) {
      throw Exception('فشل في مشاركة النسخة الاحتياطية: $e');
    }
  }

  Future<void> restoreFromJson(String backupName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups/$backupName');
      final compressedFile = File('${backupDir.path}/data.gz');

      if (await compressedFile.exists()) {
        // Read and decompress the data
        final List<int> compressedData = await compressedFile.readAsBytes();
        final List<int> decompressedBytes =
            GZipDecoder().decodeBytes(compressedData);
        final jsonData = utf8.decode(decompressedBytes);

        final data = json.decode(jsonData) as List;
        await dbHelper.clearAllBeneficiaries();

        for (var item in data) {
          final restoredItem = Map<String, dynamic>.from(item);
          if (restoredItem['image1Path'] != null &&
              restoredItem['image1Path'].isNotEmpty) {
            final String? newPath = await _decodeImageFromBase64(
                restoredItem['image1Path'],
                path.basename(restoredItem['image1Path']));
            restoredItem['image1Path'] = newPath;
          }
          if (restoredItem['image2Path'] != null &&
              restoredItem['image2Path'].isNotEmpty) {
            final String? newPath = await _decodeImageFromBase64(
                restoredItem['image2Path'],
                path.basename(restoredItem['image2Path']));
            restoredItem['image2Path'] = newPath;
          }
          await dbHelper.insertBeneficiary(restoredItem);
        }
      } else {
        throw Exception('النسخة الاحتياطية غير موجودة');
      }
    } catch (e) {
      throw Exception('فشل في استعادة النسخة الاحتياطية: $e');
    }
  }

  Future<void> restoreFromExternalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Read and decompress the data
        final List<int> compressedData = await file.readAsBytes();
        final List<int> decompressedBytes =
            GZipDecoder().decodeBytes(compressedData);
        final jsonData = utf8.decode(decompressedBytes);

        final data = json.decode(jsonData) as List;
        await dbHelper.clearAllBeneficiaries();

        for (var item in data) {
          final restoredItem = Map<String, dynamic>.from(item);

          if (restoredItem.containsKey('image1Path') &&
              restoredItem['image1Path'] != null &&
              restoredItem['image1Path'].isNotEmpty) {
            final String? newPath = await _decodeImageFromBase64(
                restoredItem['image1Path'],
                path.basename(restoredItem['image1Path']));
            restoredItem['image1Path'] = newPath;
          }

          if (restoredItem.containsKey('image2Path') &&
              restoredItem['image2Path'] != null &&
              restoredItem['image2Path'].isNotEmpty) {
            final String? newPath = await _decodeImageFromBase64(
                restoredItem['image2Path'],
                path.basename(restoredItem['image2Path']));
            restoredItem['image2Path'] = newPath;
          }

          await dbHelper.insertBeneficiary(restoredItem);
        }
      } else {
        throw Exception('الملف غير موجود');
      }
    } catch (e) {
      throw Exception('فشل في استعادة البيانات من الملف الخارجي: $e');
    }
  }

  Future<List<String>> getBackupsList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${directory.path}/backups');
      if (!await backupsDir.exists()) {
        return [];
      }
      final directories = await backupsDir
          .list()
          .where((entity) => entity is Directory)
          .toList();
      return directories.map((dir) => path.basename(dir.path)).toList();
    } catch (e) {
      throw Exception('فشل في استرداد قائمة النسخ الاحتياطية: $e');
    }
  }
}
