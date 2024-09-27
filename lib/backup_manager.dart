import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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

  Future<String> _copyImageToExternal(String imagePath) async {
    if (imagePath.isEmpty) return '';
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      final String fileName = path.basename(imageFile.path);
      final externalDir = await _externalDirectory;
      final String newPath = '${externalDir.path}/$fileName';
      await imageFile.copy(newPath);
      return newPath;
    }
    return '';
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
        if (item['image_path'] != null && item['image_path'].isNotEmpty) {
          final String newPath = await _copyImageToExternal(item['image_path']);
          modifiedItem['image_path'] =
              newPath.isNotEmpty ? path.basename(newPath) : null;
        }
        modifiedData.add(modifiedItem);
      }

      final jsonData = json.encode(modifiedData);
      final file = File('${backupDir.path}/data.json');
      await file.writeAsString(jsonData);
    } catch (e) {
      throw Exception('فشل في إنشاء النسخة الاحتياطية: $e');
    }
  }

  Future<void> restoreFromJson(String backupName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups/$backupName');
      final file = File('${backupDir.path}/data.json');

      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final data = json.decode(jsonData) as List;
        await dbHelper.clearAllBeneficiaries();

        final externalDir = await _externalDirectory;

        for (var item in data) {
          final restoredItem = Map<String, dynamic>.from(item);
          if (restoredItem['image_path'] != null &&
              restoredItem['image_path'].isNotEmpty) {
            final String fileName = restoredItem['image_path'];
            final String fullPath = '${externalDir.path}/$fileName';
            if (await File(fullPath).exists()) {
              restoredItem['image_path'] = fullPath;
            } else {
              restoredItem['image_path'] = null;
            }
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
        final jsonData = await file.readAsString();
        final data = json.decode(jsonData);

        if (data is! List) {
          throw const FormatException(
              'تنسيق البيانات غير صحيح: يجب أن تكون البيانات قائمة');
        }

        if (data.isEmpty) {
          throw const FormatException(
              'الملف فارغ أو لا يحتوي على بيانات صالحة');
        }

        final externalDir = await _externalDirectory;
        await dbHelper.clearAllBeneficiaries();

        for (var item in data) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
                'تنسيق البيانات غير صحيح: يجب أن يكون كل عنصر كائنًا');
          }

          final restoredItem = Map<String, dynamic>.from(item);
          if (restoredItem['image_path'] != null &&
              restoredItem['image_path'].isNotEmpty) {
            final String fileName = path.basename(restoredItem['image_path']);
            final String sourcePath =
                path.join(path.dirname(filePath), fileName);
            final String destPath = '${externalDir.path}/$fileName';
            final File sourceFile = File(sourcePath);
            if (await sourceFile.exists()) {
              await sourceFile.copy(destPath);
              restoredItem['image_path'] = destPath;
            } else {
              restoredItem['image_path'] = null;
            }
          }
          await dbHelper.insertBeneficiary(restoredItem);
        }
      } else {
        throw Exception('الملف غير موجود');
      }
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
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
