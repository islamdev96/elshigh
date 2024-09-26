import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'backup_manager.dart';

class SettingsPage extends StatefulWidget {
  final BackupManager backupManager;

  const SettingsPage({super.key, required this.backupManager});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildSettingButton(
              icon: Icons.backup,
              label: 'نسخ احتياطي',
              onPressed: _backupData,
            ),
            const SizedBox(height: 20),
            _buildSettingButton(
              icon: Icons.restore,
              label: 'استعادة البيانات',
              onPressed: _restoreData,
            ),
            const SizedBox(height: 20),
            _buildSettingButton(
              icon: Icons.file_upload,
              label: 'استعادة من ملف خارجي',
              onPressed: _restoreFromExternalFile,
            ),
            const SizedBox(height: 20),
            _buildSettingButton(
              icon: Icons.share,
              label: 'مشاركة النسخة الاحتياطية',
              onPressed: _shareBackup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 48),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  Future<void> _backupData() async {
    final DateTime now = DateTime.now();
    final String defaultName = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final String? backupName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = defaultName;
        return AlertDialog(
          title: const Text('تسمية النسخة الاحتياطية'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: InputDecoration(
              hintText: defaultName,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () => Navigator.of(context).pop(name),
            ),
          ],
        );
      },
    );

    if (backupName != null && backupName.isNotEmpty) {
      try {
        await widget.backupManager.backupToJson(backupName);
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

  Future<void> _restoreData() async {
    try {
      final List<String> backups = await widget.backupManager.getBackupsList();

      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد نسخ احتياطية متاحة')),
        );
        return;
      }

      final String? selectedBackup = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('اختر النسخة الاحتياطية للاستعادة'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: backups.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(backups[index]),
                    onTap: () => Navigator.of(context).pop(backups[index]),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedBackup != null) {
        await widget.backupManager.restoreFromJson(selectedBackup);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم استعادة البيانات بنجاح من: $selectedBackup')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء استعادة البيانات: $e')),
      );
    }
  }

  Future<void> _restoreFromExternalFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (file.path.toLowerCase().endsWith('.json')) {
          await widget.backupManager.restoreFromExternalFile(file.path);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم استعادة البيانات بنجاح من الملف الخارجي')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرجاء اختيار ملف بتنسيق JSON صالح')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء اختيار الملف')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('حدث خطأ أثناء استعادة البيانات من الملف الخارجي: $e')),
      );
    }
  }

  Future<void> _shareBackup() async {
    try {
      final List<String> backups = await widget.backupManager.getBackupsList();

      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد نسخ احتياطية متاحة للمشاركة')),
        );
        return;
      }

      final String? selectedBackup = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('اختر النسخة الاحتياطية للمشاركة'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: backups.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(backups[index]),
                    onTap: () => Navigator.of(context).pop(backups[index]),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedBackup != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/backup_$selectedBackup.json');

        if (await file.exists()) {
          await Share.shareXFiles([XFile(file.path)],
              subject: 'مشاركة النسخة الاحتياطية',
              text: 'مشاركة النسخة الاحتياطية: $selectedBackup');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ملف النسخة الاحتياطية غير موجود')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء مشاركة النسخة الاحتياطية: $e')),
      );
    }
  }
}
