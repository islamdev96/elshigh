import 'package:flutter/material.dart';
import 'dart:io';

/// عنصر واجهة مستخدم لعرض معلومات مستفيد بشكل بطاقة جميلة مع صورة، اسم، بيانات اتصال، وأيقونة حذف.
/// كما يوفر نافذة لعرض الصور بشكل مكبّر ويمكن التنقل بينها.
class BeneficiaryTile extends StatelessWidget {
  final Map<String, dynamic> beneficiary; // بيانات المستفيد.
  final VoidCallback onTap; // دالة لاستدعاء عند النقر على البطاقة.
  final VoidCallback onDelete; // دالة لاستدعاء عند النقر على زر الحذف.

  const BeneficiaryTile({
    super.key,
    required this.beneficiary,
    required this.onTap,
    required this.onDelete,
  });

  /// نافذة لعرض صور المستفيد مع تكبير وتصغير وإمكانية التنقل بين الصور.
  void _showImageDialog(BuildContext context, List<String?> imagePaths) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView.builder(
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = imagePaths[index];
                if (imagePath != null) {
                  return InteractiveViewer(
                    panEnabled: true, // يسمح بتحريك الصورة.
                    minScale: 0.8, // أدنى مستوى للتكبير.
                    maxScale: 3.0, // أقصى مستوى للتكبير.
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "لا توجد صورة",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap, // ينفذ عند الضغط على البطاقة.
        leading: GestureDetector(
          onTap: () {
            _showImageDialog(context,
                [beneficiary['image1Path'], beneficiary['image2Path']]);
          },
          child: _buildLeadingImage(), // إعداد الصورة بجانب المعلومات.
        ),
        title: _buildTitle(), // إعداد العنوان (الاسم واسم الزوج/ة).
        subtitle: _buildSubtitle(), // إعداد النص الفرعي (الهاتف والعنوان).
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete, // ينفذ عند الضغط على زر الحذف.
        ),
        isThreeLine: true,
      ),
    );
  }

  /// إنشاء الصورة الرمزية (leading image) لعرض صورة المستفيد أو صورة افتراضية.
  Widget _buildLeadingImage() {
    if (beneficiary['image1Path'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(beneficiary['image1Path']),
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.1),
          colorBlendMode: BlendMode.darken, // تحسين وضوح الصورة.
        ),
      );
    } else {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.teal.shade200,
        child: const Icon(Icons.person, size: 36, color: Colors.white),
      );
    }
  }

  /// إعداد العنوان الذي يحتوي على اسم المستفيد واسم الزوج/ة إذا كان موجودًا.
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          beneficiary['name'],
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        if (beneficiary['spouse_name'] != null &&
            beneficiary['spouse_name'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'الزوج/ة: ${beneficiary['spouse_name']}',
              style: TextStyle(fontSize: 14, color: Colors.teal.shade600),
            ),
          ),
      ],
    );
  }

  /// إعداد النص الفرعي الذي يحتوي على رقم الهاتف والعنوان.
  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${beneficiary['phone']}',
            style: TextStyle(fontSize: 14, color: Colors.teal.shade800),
          ),
          const SizedBox(height: 4),
          Text(
            '${beneficiary['address']}',
            style: TextStyle(fontSize: 14, color: Colors.teal.shade700),
          ),
        ],
      ),
    );
  }
}
