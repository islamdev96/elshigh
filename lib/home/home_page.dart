// الاستيرادات
import 'package:elshigh/data/pdf.dart'; // تأكد من استيراد exportAndSharePdf
import 'package:flutter/material.dart';
import 'package:elshigh/data/backup_manager.dart';
import '../Add_a_new_user/beneficiary_form.dart';
import '../data/database_helper.dart';
import 'beneficiary_tile.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

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
        final region = (beneficiary['region'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            spouseName.contains(searchLower) ||
            phone.contains(searchLower) ||
            region.contains(searchLower);
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
          title: const Text(
            "عباد الرحمن",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadBeneficiaries,
              tooltip: 'تحديث البيانات',
            ),
          ],
          elevation: 4,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal.shade700,
                ),
                child: const Center(
                  child: Text(
                    'القائمة',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home,
                text: 'الصفحة الرئيسية',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                text: 'الإعدادات',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        backupManager: backupManager,
                      ),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.share,
                text: 'مشاركة PDF',
                onTap: () => PdfExportService.exportAndSharePdf(context),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText:
                      'ابحث عن طريق الاسم، اسم الزوج، رقم الهاتف، أو المنطقة',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onChanged: _filterBeneficiaries,
              ),
            ),
            Expanded(
              child: filteredBeneficiaries.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: TextStyle(fontSize: 20, color: Colors.teal),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
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
                                  isReadOnly: false,
                                ),
                              ),
                            ).then((_) => _loadBeneficiaries());
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
            ).then((_) => _loadBeneficiaries());
          },
          backgroundColor: Colors.teal,
          tooltip: 'إضافة شخص جديد',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(text,
          style: TextStyle(fontSize: 18, color: Colors.teal.shade800)),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
