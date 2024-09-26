import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'backup_manager.dart';

class SettingsPage extends StatefulWidget {
  final BackupManager backupManager;

  const SettingsPage({Key? key, required this.backupManager}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryGreen = Color(0xFF00796B); // Dark Teal
  final Color secondaryGreen = Color(0xFF009688); // Medium Teal
  final Color lightGreen = Color(0xFF4DB6AC); // Light Teal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryGreen,
              lightGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                _buildSettingCard(
                  icon: Icons.backup,
                  label: 'نسخ احتياطي',
                  onPressed: _backupData,
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.restore,
                  label: 'استعادة البيانات',
                  onPressed: _restoreData,
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.file_upload,
                  label: 'استعادة من ملف خارجي',
                  onPressed: _restoreFromExternalFile,
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.share,
                  label: 'مشاركة النسخة الاحتياطية',
                  onPressed: _shareBackup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 32, color: secondaryGreen),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: primaryGreen),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: lightGreen),
            ],
          ),
        ),
      ),
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
        await widget.backupManager.backupToJson(backupName);
        _showSnackBar('تم النسخ الاحتياطي بنجاح: $backupName');
      } catch (e) {
        _showSnackBar('حدث خطأ أثناء النسخ الاحتياطي: $e');
      }
    }
  }

  Future<void> _restoreData() async {
    try {
      final List<String> backups = await widget.backupManager.getBackupsList();

      if (backups.isEmpty) {
        _showSnackBar('لا توجد نسخ احتياطية متاحة');
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
        _showSnackBar('تم استعادة البيانات بنجاح من: $selectedBackup');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء استعادة البيانات: $e');
    }
  }

  Future<void> _restoreFromExternalFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (file.path.toLowerCase().endsWith('.json')) {
          await widget.backupManager.restoreFromExternalFile(file.path);
          setState(() {});
          _showSnackBar('تم استعادة البيانات بنجاح من الملف الخارجي');
        } else {
          _showSnackBar('الرجاء اختيار ملف بتنسيق JSON صالح');
        }
      } else {
        _showSnackBar('تم إلغاء اختيار الملف');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء استعادة البيانات من الملف الخارجي: $e');
    }
  }

  Future<void> _shareBackup() async {
    try {
      final List<String> backups = await widget.backupManager.getBackupsList();

      if (backups.isEmpty) {
        _showSnackBar('لا توجد نسخ احتياطية متاحة للمشاركة');
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
        final backupDir =
            Directory('${directory.path}/backups/$selectedBackup');
        final file = File('${backupDir.path}/data.json');

        if (await file.exists()) {
          await Share.shareXFiles([XFile(file.path)],
              subject: 'مشاركة النسخة الاحتياطية',
              text: 'مشاركة النسخة الاحتياطية: $selectedBackup');
        } else {
          _showSnackBar('ملف النسخة الاحتياطية غير موجود');
        }
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء مشاركة النسخة الاحتياطية: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
