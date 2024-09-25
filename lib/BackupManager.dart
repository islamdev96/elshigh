import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:convert'; // لاستخدام JSON

class BackupManager {
  final DatabaseHelper dbHelper;

  BackupManager(this.dbHelper);

  // دالة لحفظ البيانات كـ JSON
  Future<void> backupToJson() async {
    try {
      final beneficiaries = await dbHelper.getBeneficiaries();

      if (beneficiaries.isNotEmpty) {
        String jsonData = jsonEncode(beneficiaries);
        String filePath = await _getFilePath('backup.json');
        File file = File(filePath);
        await file.writeAsString(jsonData);
        print('تم حفظ النسخة الاحتياطية بنجاح: $filePath');
      } else {
        print('لا توجد بيانات لحفظ النسخة الاحتياطية.');
      }
    } catch (e) {
      print('حدث خطأ أثناء حفظ النسخة الاحتياطية: $e');
    }
  }

  // دالة لحفظ البيانات كـ CSV
  Future<void> backupToCsv() async {
    try {
      final beneficiaries = await dbHelper.getBeneficiaries();

      if (beneficiaries.isNotEmpty) {
        List<String> csvData = [];
        // إضافة رؤوس الأعمدة
        csvData.add('ID,Name,Phone,Address,Notes');

        for (var beneficiary in beneficiaries) {
          csvData.add(
              '${beneficiary['id']},${beneficiary['name']},${beneficiary['phone']},${beneficiary['address']},${beneficiary['notes']}');
        }

        String filePath = await _getFilePath('backup.csv');
        File file = File(filePath);
        await file.writeAsString(csvData.join('\n'));
        print('تم حفظ النسخة الاحتياطية بنجاح: $filePath');
      } else {
        print('لا توجد بيانات لحفظ النسخة الاحتياطية.');
      }
    } catch (e) {
      print('حدث خطأ أثناء حفظ النسخة الاحتياطية: $e');
    }
  }

  // الحصول على مسار حفظ الملف
  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}
