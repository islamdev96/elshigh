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
        final data = json.decode(jsonData) as List<dynamic>;

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
}
