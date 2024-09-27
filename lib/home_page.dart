import 'package:elshigh/backup_manager.dart';
import 'package:flutter/material.dart';
import 'beneficiary_form.dart';
import 'database_helper.dart';
import 'beneficiary_tile.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

///
class _HomePageState extends State<HomePage> {
  late DatabaseHelper dbHelper;
  late BackupManager backupManager;
  List<Map<String, dynamic>> allBeneficiaries = [];
  List<Map<String, dynamic>> filteredBeneficiaries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    backupManager = BackupManager(dbHelper);
    _loadBeneficiaries();
  }

  Future<void> _loadBeneficiaries() async {
    allBeneficiaries = await dbHelper.getBeneficiaries();
    setState(() {
      filteredBeneficiaries = allBeneficiaries;
    });
  }

  void _filterBeneficiaries(String query) {
    setState(() {
      filteredBeneficiaries = allBeneficiaries.where((beneficiary) {
        final name = beneficiary['name'].toLowerCase();
        final spouseName = (beneficiary['spouse_name'] ?? '').toLowerCase();
        final phone = beneficiary['phone'].toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            spouseName.contains(searchLower) ||
            phone.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _deleteBeneficiary(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحذير'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الشخص؟'),
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
      _loadBeneficiaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("عباد الرحمن"),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadBeneficiaries(); // Call the function to refresh the data
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Text(
                  'القائمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('الصفحة الرئيسية'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('الإعدادات'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsPage(backupManager: backupManager),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'بحث',
                  hintText: 'ابحث عن طريق الاسم أو اسم الزوج أو رقم الهاتف',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: _filterBeneficiaries,
              ),
            ),
            Expanded(
              child: filteredBeneficiaries.isEmpty
                  ? const Center(
                      child: Text('لا توجد نتائج',
                          style: TextStyle(fontSize: 18, color: Colors.teal)))
                  : ListView.builder(
                      itemCount: filteredBeneficiaries.length,
                      itemBuilder: (context, index) {
                        final beneficiary = filteredBeneficiaries[index];
                        return BeneficiaryTile(
                          beneficiary: beneficiary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BeneficiaryForm(
                                    beneficiary: beneficiary,
                                    isReadOnly: false),
                              ),
                            ).then((_) {
                              _loadBeneficiaries();
                            });
                          },
                          onDelete: () => _deleteBeneficiary(beneficiary['id']),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BeneficiaryForm()),
            ).then((_) {
              _loadBeneficiaries();
            });
          },
          backgroundColor: Colors.teal,
          tooltip: 'إضافة شخص جديد',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
