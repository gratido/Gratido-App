// lib/features/donor/edit_profile_provider.dart
// ignore_for_file: use_super_parameters

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileProviderPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photoPath;

  const EditProfileProviderPage({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.photoPath,
  }) : super(key: key);

  @override
  State<EditProfileProviderPage> createState() =>
      _EditProfileProviderPageState();
}

class _EditProfileProviderPageState extends State<EditProfileProviderPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // 🎨 FINAL BRAND COLORS
  static const Color primary = Color(0xFF6E5CD6);
  static const Color softBg = Color(0xFFF7F3FF);
  static const Color gradientTop = Color(0xFFEDE9FE);

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    if (widget.photoPath != null && widget.photoPath!.isNotEmpty) {
      _pickedImage = XFile(widget.photoPath!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  void _saveDetails() {
    Navigator.pop(context, {
      'name': nameController.text.isEmpty
          ? widget.name
          : nameController.text.trim(),
      'email': emailController.text.isEmpty
          ? widget.email
          : emailController.text.trim(),
      'phone': phoneController.text.isEmpty
          ? widget.phone
          : phoneController.text.trim(),
      'address': addressController.text.isEmpty
          ? widget.address
          : addressController.text.trim(),
      'photo': _pickedImage?.path,
    });
  }

  ImageProvider? _fileImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      if (kIsWeb) return null;
      final f = File(path);
      if (!f.existsSync()) return null;
      return FileImage(f);
    } catch (_) {
      return null;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔮 TOP GRADIENT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientTop,
                    softBg,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // 👤 AVATAR
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _pickedImage != null
                              ? (kIsWeb
                                  ? null
                                  : FileImage(File(_pickedImage!.path)))
                              : _fileImageProvider(widget.photoPath),
                          child: (_pickedImage == null &&
                                  _fileImageProvider(widget.photoPath) == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✍️ FORM
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration(
                      widget.name.isNotEmpty ? widget.name : 'Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      widget.email.isNotEmpty ? widget.email : 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      widget.phone.isNotEmpty ? widget.phone : 'Phone number',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      widget.address.isNotEmpty
                          ? widget.address
                          : 'Default Address',
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 💜 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                        shadowColor: primary.withOpacity(0.45),
                      ),
                      child: const Text(
                        'Save my details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
