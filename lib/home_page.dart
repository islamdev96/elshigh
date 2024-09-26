import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'beneficiary_form.dart';
import 'database_helper.dart';
import 'beneficiary_tile.dart';
import 'backup_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper dbHelper;
  late BackupManager backupManager;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    backupManager = BackupManager(dbHelper);
  }

  Future<List<Map<String, dynamic>>> _getBeneficiaries() async {
    return await dbHelper.getBeneficiaries();
  }

  Future<void> _deleteBeneficiary(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحذير'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا المستفيد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await dbHelper.deleteBeneficiary(id);
      setState(() {});
    }
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

  Future<void> _restoreData() async {
    try {
      final List<String> backups = await backupManager.getBackupsList();

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
        await backupManager.restoreFromJson(selectedBackup);
        setState(() {}); // تحديث واجهة المستخدم بعد الاستعادة
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جمعية خيرية'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: 'نسخ احتياطي',
            onPressed: _backupData,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'استعادة البيانات',
            onPressed: _restoreData,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getBeneficiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('حدث خطأ: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('لا يوجد بيانات محفوظة',
                    style: TextStyle(fontSize: 18, color: Colors.teal)));
          } else {
            final beneficiaries = snapshot.data!;
            return ListView.builder(
              itemCount: beneficiaries.length,
              itemBuilder: (context, index) {
                final beneficiary = beneficiaries[index];
                return BeneficiaryTile(
                  beneficiary: beneficiary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BeneficiaryForm(
                            beneficiary: beneficiary, isReadOnly: false),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  onDelete: () => _deleteBeneficiary(beneficiary['id']),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BeneficiaryForm()),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: Colors.teal,
        tooltip: 'إضافة مستفيد جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
