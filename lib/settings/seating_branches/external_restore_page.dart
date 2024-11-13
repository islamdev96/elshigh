import 'package:elshigh/settings/SettingsScaffold.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/backup_manager.dart';

class ExternalRestorePage extends StatelessWidget {
  final BackupManager backupManager;

  const ExternalRestorePage({Key? key, required this.backupManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'استعادة من ملف خارجي',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _restoreFromExternalFile(context),
                child: const Text('اختيار ملف للاستعادة'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restoreFromExternalFile(BuildContext context) async {
    try {
      // استخدام FileType.any بدلاً من FileType.custom
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // تغيير نوع الملف إلى any
        allowMultiple: false,
      );

      if (result == null) {
        debugPrint('لم يتم اختيار ملف');
        return;
      }

      if (result.files.isEmpty) {
        _showError(context, 'الملف المحدد غير صالح');
        return;
      }

      String? filePath = result.files.single.path;
      if (filePath == null) {
        _showError(context, 'مسار الملف غير صالح');
        return;
      }

      // التحقق من امتداد الملف يدويًا
      if (!filePath.toLowerCase().endsWith('.gz')) {
        _showError(context, 'الرجاء اختيار ملف بصيغة .gz');
        return;
      }

      File file = File(filePath);

      // التحقق من وجود الملف
      if (!await file.exists()) {
        _showError(context, 'الملف غير موجود في المسار المحدد');
        return;
      }

      // التحقق من حجم الملف
      int fileSize = await file.length();
      if (fileSize == 0) {
        _showError(context, 'الملف فارغ');
        return;
      }

      // عرض مربع حوار التأكيد
      bool? confirmRestore = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تأكيد الاستعادة'),
            content: const Text(
              'سيتم حذف جميع البيانات الحالية واستبدالها بالبيانات من النسخة الاحتياطية. هل أنت متأكد من الاستمرار؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('استعادة'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmRestore == true) {
        await _showProgressDialog(context, file);
      }
    } catch (e, stackTrace) {
      debugPrint('خطأ في اختيار الملف: $e');
      debugPrint('Stack trace: $stackTrace');
      _showError(context, 'حدث خطأ غير متوقع: $e');
    }
  }

  Future<void> _showProgressDialog(BuildContext context, File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري استعادة البيانات...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      await backupManager.restoreFromExternalFile(file.path);

      if (context.mounted) {
        Navigator.of(context).pop(); // إغلاق مربع حوار التقدم
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استعادة البيانات بنجاح')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('خطأ في استعادة البيانات: $e');
      debugPrint('Stack trace: $stackTrace');

      if (context.mounted) {
        Navigator.of(context).pop(); // إغلاق مربع حوار التقدم
        _showError(context, 'فشل في استعادة البيانات: $e');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
