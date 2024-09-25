import 'package:flutter/material.dart';
import 'beneficiary_form.dart';
import 'database_helper.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جمعية خيرية'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: beneficiary['image1Path'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(beneficiary['image1Path']),
                                  width: 70, height: 70, fit: BoxFit.cover),
                            )
                          : CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.teal.shade100,
                              child: const Icon(Icons.person,
                                  size: 40, color: Colors.teal),
                            ),
                      title: Text(
                        beneficiary['name'],
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700),
                      ),
                      subtitle: Text(
                        '${beneficiary['phone']}\n${beneficiary['address']}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.teal.shade600),
                      ),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBeneficiary(beneficiary['id']),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            }
          },
        ),
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
