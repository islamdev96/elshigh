import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'dart:io';

class BeneficiaryForm extends StatefulWidget {
  final Map<String, dynamic>? beneficiary;
  final bool isReadOnly;

  const BeneficiaryForm({super.key, this.beneficiary, this.isReadOnly = false});

  @override
  _BeneficiaryFormState createState() => _BeneficiaryFormState();
}

class _BeneficiaryFormState extends State<BeneficiaryForm> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _image1;
  File? _image2;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.beneficiary != null) {
      _nameController.text = widget.beneficiary!['name'];
      _spouseNameController.text = widget.beneficiary!['spouse_name'] ?? '';
      _phoneController.text = widget.beneficiary!['phone'];
      _addressController.text = widget.beneficiary!['address'];
      _notesController.text = widget.beneficiary!['notes'];
      _image1 = widget.beneficiary!['image1Path'] != null
          ? File(widget.beneficiary!['image1Path'])
          : null;
      _image2 = widget.beneficiary!['image2Path'] != null
          ? File(widget.beneficiary!['image2Path'])
          : null;
    }
  }

  Future<void> _pickImage(int imageNumber) async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار صورة'),
        content: const Text('اختر طريقة اختيار الصورة:'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, image);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('من المعرض'),
          ),
          TextButton.icon(
            onPressed: () async {
              final image = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, image);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('التقاط صورة'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveData() async {
    final dbHelper = DatabaseHelper();
    final data = {
      'name': _nameController.text,
      'spouse_name': _spouseNameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'notes': _notesController.text,
      'image1Path': _image1?.path,
      'image2Path': _image2?.path,
    };

    if (widget.beneficiary == null) {
      await dbHelper.insertBeneficiary(data);
    } else {
      await dbHelper.updateBeneficiary(widget.beneficiary!['id'], data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ البيانات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      filled: true,
      fillColor: Colors.teal.shade50,
      labelStyle: TextStyle(color: Colors.teal.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isReadOnly ? 'عرض بيانات المستفيد' : 'إضافة مستفيد جديد'),
        backgroundColor: Colors.teal,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal.shade50, Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                _buildInputDecoration('الاسم', Icons.person),
                            readOnly: widget.isReadOnly,
                            validator: (value) {
                              if (!widget.isReadOnly &&
                                  (value == null || value.isEmpty)) {
                                return 'يرجى إدخال الاسم';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _spouseNameController,
                            decoration: _buildInputDecoration(
                                'اسم الزوج/ة', Icons.person_outline),
                            readOnly: widget.isReadOnly,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: _buildInputDecoration(
                                'رقم الهاتف', Icons.phone),
                            keyboardType: TextInputType.phone,
                            readOnly: widget.isReadOnly,
                            validator: (value) {
                              if (!widget.isReadOnly &&
                                  (value == null || value.isEmpty)) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: _buildInputDecoration(
                                'العنوان', Icons.location_on),
                            readOnly: widget.isReadOnly,
                            validator: (value) {
                              if (!widget.isReadOnly &&
                                  (value == null || value.isEmpty)) {
                                return 'يرجى إدخال العنوان';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration:
                                _buildInputDecoration('ملاحظات', Icons.note),
                            maxLines: 5,
                            readOnly: widget.isReadOnly,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'الصور',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: widget.isReadOnly
                                        ? null
                                        : () => _pickImage(1),
                                    icon: const Icon(Icons.image),
                                    label: const Text('الصورة الأولى'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (_image1 != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_image1!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: widget.isReadOnly
                                        ? null
                                        : () => _pickImage(2),
                                    icon: const Icon(Icons.image),
                                    label: const Text('الصورة الثانية'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (_image2 != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_image2!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!widget.isReadOnly)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('حفظ البيانات',
                          style: TextStyle(fontSize: 18)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
