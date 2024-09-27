import 'package:flutter/material.dart';
import 'dart:io';

class BeneficiaryTile extends StatelessWidget {
  final Map<String, dynamic> beneficiary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BeneficiaryTile({
    super.key,
    required this.beneficiary,
    required this.onTap,
    required this.onDelete,
  });

  void _showImageDialog(BuildContext context, List<String?> imagePaths) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PageView.builder(
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = imagePaths[index];
              if (imagePath != null) {
                return InteractiveViewer(
                  //  للسماح بالتكبير/التصغير
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 2.5,
                  boundaryMargin: const EdgeInsets.all(double
                      .infinity), // يسمح بتحريك الصورة خارج حدودها الأصلية
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return const Center(child: Text("لا توجد صورة"));
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: GestureDetector(
          onTap: () {
            _showImageDialog(context,
                [beneficiary['image1Path'], beneficiary['image2Path']]);
          },
          child: _buildLeadingImage(),
        ),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (beneficiary['image1Path'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(beneficiary['image1Path']),
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.teal.shade100,
        child: const Icon(Icons.person, size: 40, color: Colors.teal),
      );
    }
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          beneficiary['name'],
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700),
        ),
        if (beneficiary['spouse_name'] != null &&
            beneficiary['spouse_name'].isNotEmpty)
          Text(
            'الزوج/ة: ${beneficiary['spouse_name']}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.teal.shade600),
          ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '${beneficiary['phone']}\n${beneficiary['address']}',
      style: TextStyle(fontSize: 14, color: Colors.teal.shade600),
    );
  }
}
