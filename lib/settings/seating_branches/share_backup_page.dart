// settings/share_backup_page.dart
import 'package:elshigh/settings/SettingsScaffold.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/backup_manager.dart';

class ShareBackupPage extends StatefulWidget {
  final BackupManager backupManager;

  const ShareBackupPage({Key? key, required this.backupManager})
      : super(key: key);

  @override
  _ShareBackupPageState createState() => _ShareBackupPageState();
}

class _ShareBackupPageState extends State<ShareBackupPage> {
  List<String> backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final List<String> loadedBackups =
        await widget.backupManager.getBackupsList();
    setState(() {
      backups = loadedBackups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'مشاركة النسخة الاحتياطية',
      body: backups.isEmpty
          ? Center(
              child: Text(
                'لا توجد نسخ احتياطية متاحة للمشاركة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          : ListView.builder(
              itemCount: backups.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(backups[index]),
                    trailing: Icon(Icons.share),
                    onTap: () => _shareBackup(backups[index]),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _shareBackup(String backupName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups/$backupName');
      final compressedFile = File('${backupDir.path}/data.gz');

      if (await compressedFile.exists()) {
        await Share.shareXFiles(
          [XFile(compressedFile.path)],
          subject: 'مشاركة النسخة الاحتياطية',
          text: 'مشاركة النسخة الاحتياطية: $backupName',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ملف النسخة الاحتياطية غير موجود')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء مشاركة النسخة الاحتياطية: $e')),
      );
    }
  }
}
