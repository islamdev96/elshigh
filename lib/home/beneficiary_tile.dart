// ملف: beneficiary_tile.dart

import 'package:elshigh/home/images/image_viewer.dart';
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

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageViewer(
            imagePaths: [beneficiary['image1Path'], beneficiary['image2Path']]);
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
        onTap: onTap,
        leading: GestureDetector(
          onTap: () => _showImageDialog(context),
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
          color: Colors.black.withOpacity(0.1),
          colorBlendMode: BlendMode.darken,
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
