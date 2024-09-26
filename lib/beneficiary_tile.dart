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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                child: const Icon(Icons.person, size: 40, color: Colors.teal),
              ),
        title: Column(
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
        ),
        subtitle: Text(
          '${beneficiary['phone']}\n${beneficiary['address']}',
          style: TextStyle(fontSize: 14, color: Colors.teal.shade600),
        ),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        isThreeLine: true,
      ),
    );
  }
}
