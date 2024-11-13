import 'dart:io';
import 'package:elshigh/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// ignore: unused_shown_name
import 'package:flutter/services.dart' show FontLoader, rootBundle;

class PdfExportService {
  static Future<void> exportAndSharePdf(BuildContext context) async {
    try {
      // تحميل خط Cairo
      final cairoFontRegular =
          await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final cairoFontBold =
          await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

      final regularFont = pw.Font.ttf(cairoFontRegular);
      final boldFont = pw.Font.ttf(cairoFontBold);

      // إنشاء مستند PDF
      final pdf = pw.Document();

      // الحصول على البيانات من قاعدة البيانات
      final dbHelper = DatabaseHelper();
      final beneficiaries = await dbHelper.getBeneficiaries();

      if (beneficiaries.isEmpty) {
        throw Exception('لا توجد بيانات للمستفيدين');
      }

      // إضافة صفحة العنوان
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'تقرير المستفيدين',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'تاريخ التقرير: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(font: regularFont, fontSize: 16),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      );

      // إضافة صفحات البيانات
      for (var i = 0; i < beneficiaries.length; i += 3) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'صفحة ${(i ~/ 3) + 1}',
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                        ),
                        pw.Text(
                          'بيانات المستفيدين',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 18,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  ...List.generate(
                    3,
                    (index) {
                      if (i + index < beneficiaries.length) {
                        final beneficiary = beneficiaries[i + index];
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            _buildBeneficiarySection(
                              beneficiary,
                              regularFont,
                              boldFont,
                            ),
                            if (index < 2 &&
                                i + index < beneficiaries.length - 1)
                              pw.Divider(),
                          ],
                        );
                      }
                      return pw.Container();
                    },
                  ),
                ],
              );
            },
          ),
        );
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/beneficiaries_report.pdf');
      await file.writeAsBytes(await pdf.save());

      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'تقرير المستفيدين',
        subject: 'تقرير المستفيدين ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      print('خطأ في إنشاء PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إنشاء التقرير: ${e.toString()}'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static pw.Widget _buildBeneficiarySection(
    Map<String, dynamic> beneficiary,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    String _getSafeValue(dynamic value) {
      return value?.toString() ?? 'غير متوفر';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildInfoRow('الاسم:', _getSafeValue(beneficiary['name']),
              regularFont, boldFont),
          _buildInfoRow('اسم الزوج/ة:',
              _getSafeValue(beneficiary['spouse_name']), regularFont, boldFont),
          _buildInfoRow('المنطقة:', _getSafeValue(beneficiary['region']),
              regularFont, boldFont),
          _buildInfoRow('الحالة:', _getSafeValue(beneficiary['status']),
              regularFont, boldFont),
          _buildInfoRow(
              'عدد أفراد الأسرة:',
              _getSafeValue(beneficiary['family_members']),
              regularFont,
              boldFont),
          _buildInfoRow('الدرجة:', _getSafeValue(beneficiary['grade']),
              regularFont, boldFont),
          _buildInfoRow('رقم الهاتف:', _getSafeValue(beneficiary['phone']),
              regularFont, boldFont),
          _buildInfoRow('العنوان:', _getSafeValue(beneficiary['address']),
              regularFont, boldFont),
          _buildInfoRow(
              'نوع السكن:',
              _getSafeValue(beneficiary['property_type']),
              regularFont,
              boldFont),
          if (beneficiary['notes']?.isNotEmpty ?? false)
            _buildInfoRow('ملاحظات:', _getSafeValue(beneficiary['notes']),
                regularFont, boldFont),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
      String label, String value, pw.Font regularFont, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: regularFont, fontSize: 12),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
