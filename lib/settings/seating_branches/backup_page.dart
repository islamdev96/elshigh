// settings/backup_page.dart
import 'package:elshigh/settings/SettingsScaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/backup_manager.dart';

class BackupPage extends StatelessWidget {
  final BackupManager backupManager;

  const BackupPage({Key? key, required this.backupManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'نسخ احتياطي',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _backupData(context),
                child: Text('إنشاء نسخة احتياطية جديدة'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _backupData(BuildContext context) async {
    final DateTime now = DateTime.now();
    final String defaultName = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final String? backupName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = defaultName;
        return AlertDialog(
          title: const Text('تسمية النسخة الاحتياطية'),
          content: TextField(
            onChanged: (value) => name = value,
            decoration: InputDecoration(
              hintText: defaultName,
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('حفظ'),
              onPressed: () => Navigator.of(context).pop(name),
            ),
          ],
        );
      },
    );

    if (backupName != null && backupName.isNotEmpty) {
      try {
        await backupManager.backupToJson(backupName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم النسخ الاحتياطي بنجاح: $backupName')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء النسخ الاحتياطي: $e')),
        );
      }
    }
  }
}
