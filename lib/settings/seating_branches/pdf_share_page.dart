// settings/pdf_share_page.dart
import 'package:elshigh/settings/SettingsScaffold.dart';
import 'package:flutter/material.dart';
import '../../data/pdf.dart';

class PdfSharePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'مشاركة PDF',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'تصدير وثائقك إلى ملف PDF',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'سيتم تجميع كافة البيانات في ملف PDF منظم',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => PdfExportService.exportAndSharePdf(context),
                icon: Icon(Icons.share),
                label: Text('تصدير ومشاركة PDF'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF00796B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
