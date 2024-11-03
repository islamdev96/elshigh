import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'dart:io';

class BeneficiaryForm extends StatefulWidget {
  final Map<String, dynamic>? beneficiary;
  final bool isReadOnly;

  const BeneficiaryForm({Key? key, this.beneficiary, this.isReadOnly = false})
      : super(key: key);

  @override
  _BeneficiaryFormState createState() => _BeneficiaryFormState();
}

class _BeneficiaryFormState extends State<BeneficiaryForm> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _image1;
  File? _image2;

  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _familyMembersController =
      TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Theme colors
  final Color primaryColor = Colors.teal;
  final Color secondaryColor = Colors.tealAccent;
  final Color backgroundColor = Colors.grey[100]!;

  @override
  void initState() {
    super.initState();
    if (widget.beneficiary != null) {
      _regionController.text = widget.beneficiary!['region'] ?? '';
      _nameController.text = widget.beneficiary!['name'] ?? '';
      _spouseNameController.text = widget.beneficiary!['spouse_name'] ?? '';
      _statusController.text = widget.beneficiary!['status'] ?? '';
      _familyMembersController.text =
          widget.beneficiary!['family_members']?.toString() ?? '';
      _gradeController.text = widget.beneficiary!['grade'] ?? '';
      _phoneController.text = widget.beneficiary!['phone'] ?? '';
      _addressController.text = widget.beneficiary!['address'] ?? '';
      _propertyTypeController.text = widget.beneficiary!['property_type'] ?? '';
      _notesController.text = widget.beneficiary!['notes'] ?? '';

      if (widget.beneficiary!['image1Path'] != null) {
        _image1 = File(widget.beneficiary!['image1Path']);
      }
      if (widget.beneficiary!['image2Path'] != null) {
        _image2 = File(widget.beneficiary!['image2Path']);
      }
    }
  }

  Future<void> _saveData() async {
    final dbHelper = DatabaseHelper();
    final data = {
      'region': _regionController.text,
      'name': _nameController.text,
      'spouse_name': _spouseNameController.text,
      'status': _statusController.text,
      'family_members': int.tryParse(_familyMembersController.text) ?? 0,
      'grade': _gradeController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'property_type': _propertyTypeController.text,
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
      SnackBar(
        content: const Text('تم حفظ البيانات بنجاح'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isPhone = false,
    bool isMultiLine = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isPhone
                ? TextInputType.phone
                : isMultiLine
                    ? TextInputType.multiline
                    : TextInputType.text,
        maxLines: isMultiLine ? 3 : 1,
        inputFormatters: isNumber || isPhone
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: isMultiLine,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 16),
        readOnly: widget.isReadOnly,
        validator: (value) {
          if (!widget.isReadOnly && (value == null || value.isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePickerColumn(int imageNumber, File? image) {
    return Column(
      children: [
        if (!widget.isReadOnly)
          ElevatedButton.icon(
            onPressed: () => _pickImage(imageNumber),
            icon: const Icon(Icons.camera_alt),
            label: Text('صورة $imageNumber'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (image != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                image,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(int imageNumber) async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار صورة'),
        content: const Text('اختر طريقة التقاط الصورة:'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, image);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('المعرض'),
          ),
          TextButton.icon(
            onPressed: () async {
              final image = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, image);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('الكاميرا'),
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isReadOnly ? 'عرض البيانات' : 'إضافة مستفيد جديد',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المعلومات الأساسية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormField('المنطقة', _regionController),
                          _buildFormField('الاسم', _nameController),
                          _buildFormField('اسم الزوج/ة', _spouseNameController),
                          _buildFormField('الحالة', _statusController),
                          _buildFormField(
                            'عدد الأفراد',
                            _familyMembersController,
                            isNumber: true,
                          ),
                          _buildFormField('الدرجة', _gradeController),
                          _buildFormField(
                            'رقم التليفون',
                            _phoneController,
                            isPhone: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات السكن',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormField('العنوان', _addressController),
                          _buildFormField(
                            'نوع السكن',
                            _propertyTypeController,
                          ),
                          _buildFormField(
                            'ملاحظات',
                            _notesController,
                            isMultiLine: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الصور',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildImagePickerColumn(1, _image1),
                              _buildImagePickerColumn(2, _image2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!widget.isReadOnly) const SizedBox(height: 24),
                  if (!widget.isReadOnly)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'حفظ البيانات',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
