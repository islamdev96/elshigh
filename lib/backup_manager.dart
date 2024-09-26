import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';

class BackupManager {
  final DatabaseHelper dbHelper;

  BackupManager(this.dbHelper);

  Future<void> backupToJson(String backupName) async {
    try {
      final data = await dbHelper.getBeneficiaries();
      final jsonData = json.encode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_$backupName.json');
      await file.writeAsString(jsonData);
    } catch (e) {
      throw Exception('فشل في إنشاء النسخة الاحتياطية: $e');
    }
  }

  Future<void> restoreFromJson(String backupName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_$backupName.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final data = json.decode(jsonData) as List;
        await dbHelper.clearAllBeneficiaries();
        for (var item in data) {
          await dbHelper.insertBeneficiary(Map<String, dynamic>.from(item));
        }
      } else {
        throw Exception('النسخة الاحتياطية غير موجودة');
      }
    } catch (e) {
      throw Exception('فشل في استعادة النسخة الاحتياطية: $e');
    }
  }

  Future<List<String>> getBackupsList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      return files
          .map((file) => file.path
              .split('/')
              .last
              .replaceAll('backup_', '')
              .replaceAll('.json', ''))
          .toList();
    } catch (e) {
      throw Exception('فشل في استرداد قائمة النسخ الاحتياطية: $e');
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

        for (var item in data) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
                'تنسيق البيانات غير صحيح: يجب أن يكون كل عنصر كائنًا');
          }
          // يمكنك إضافة المزيد من عمليات التحقق هنا إذا لزم الأمر
        }

        await dbHelper.clearAllBeneficiaries();
        for (var item in data) {
          await dbHelper.insertBeneficiary(Map<String, dynamic>.from(item));
        }
      } else {
        throw Exception('الملف غير موجود');
      }
    } catch (e) {
      if (e is FormatException) {
        rethrow; // إعادة رمي أخطاء التنسيق ليتم التعامل معها بشكل منفصل
      }
      throw Exception('فشل في استعادة البيانات من الملف الخارجي: $e');
    }
  }
}
