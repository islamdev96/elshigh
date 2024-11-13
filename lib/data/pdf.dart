import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

Future<void> exportAndSharePdf(BuildContext context) async {
  final pdf = pw.Document();
  final databaseHelper = DatabaseHelper();
  final beneficiaries = await databaseHelper.getBeneficiaries();

  pdf.addPage(
    pw.MultiPage(
      build: (context) {
        return [
          pw.Table.fromTextArray(
            headers: [
              'Region',
              'Name',
              'Spouse',
              'Status',
              'Members',
              'Grade',
              'Phone',
              'Address',
              'Property',
              'Notes'
            ],
            data: beneficiaries.map((beneficiary) {
              return [
                beneficiary['region'],
                beneficiary['name'],
                beneficiary['spouse_name'],
                beneficiary['status'],
                beneficiary['family_members'].toString(),
                beneficiary['grade'],
                beneficiary['phone'],
                beneficiary['address'],
                beneficiary['property_type'],
                beneficiary['notes'],
              ];
            }).toList(),
          ),
        ];
      },
    ),
  );

  final documentDir = await getApplicationDocumentsDirectory();
  String fileName = 'output';

  // اطلب من المستخدم إدخال اسم الملف
  final result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String _fileName = 'output';
      return AlertDialog(
        title: Text('أدخل اسم الملف'),
        content: TextField(
          onChanged: (value) {
            _fileName = value;
          },
          decoration: InputDecoration(
            hintText: 'أدخل اسم الملف (بدون امتداد .pdf)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_fileName);
            },
            child: Text('حفظ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('إلغاء'),
          ),
        ],
      );
    },
  );

  if (result != null && result.isNotEmpty) {
    fileName = result;
  }

  final filePath = '${documentDir.path}/$fileName.pdf';
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  // مشاركة الملف
  await Share.shareXFiles([XFile(filePath)], text: 'تفضل، ملف PDF');
}
