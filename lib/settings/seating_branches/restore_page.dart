// settings/restore_page.dart
import 'package:elshigh/settings/SettingsScaffold.dart';
import 'package:flutter/material.dart';
import '../../data/backup_manager.dart';

class RestorePage extends StatefulWidget {
  final BackupManager backupManager;

  const RestorePage({Key? key, required this.backupManager}) : super(key: key);

  @override
  _RestorePageState createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
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
      title: 'استعادة البيانات',
      body: backups.isEmpty
          ? Center(
              child: Text('لا توجد نسخ احتياطية متاحة'),
            )
          : ListView.builder(
              itemCount: backups.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(backups[index]),
                    trailing: Icon(Icons.restore),
                    onTap: () => _restoreBackup(backups[index]),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _restoreBackup(String backupName) async {
    try {
      await widget.backupManager.restoreFromJson(backupName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم استعادة البيانات بنجاح من: $backupName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء استعادة البيانات: $e')),
      );
    }
  }
}
