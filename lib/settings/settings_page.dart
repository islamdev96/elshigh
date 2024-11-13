// settings/settings_page.dart
import 'package:elshigh/settings/seating_branches/backup_page.dart';
import 'package:elshigh/settings/seating_branches/external_restore_page.dart';
import 'package:elshigh/settings/seating_branches/restore_page.dart';
import 'package:flutter/material.dart';
import 'seating_branches/share_backup_page.dart';
import 'seating_branches/pdf_share_page.dart';
import '../data/backup_manager.dart';

class SettingsPage extends StatefulWidget {
  final BackupManager backupManager;

  const SettingsPage({Key? key, required this.backupManager}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryGreen = Color(0xFF00796B);
  final Color secondaryGreen = Color(0xFF009688);
  final Color lightGreen = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen.withOpacity(0.8), lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                _buildSettingCard(
                  icon: Icons.backup,
                  label: 'نسخ احتياطي',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BackupPage(backupManager: widget.backupManager),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.restore,
                  label: 'استعادة البيانات',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestorePage(backupManager: widget.backupManager),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.file_upload,
                  label: 'استعادة من ملف خارجي',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExternalRestorePage(
                          backupManager: widget.backupManager),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.share,
                  label: 'مشاركة النسخة الاحتياطية',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShareBackupPage(backupManager: widget.backupManager),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.picture_as_pdf,
                  label: 'مشاركة PDF',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfSharePage(),
                    ),
                  ),
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
      elevation: 8,
      shadowColor: Colors.tealAccent,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPressed,
        splashColor: lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 36, color: primaryGreen),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 18,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: secondaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}
