// lib/features/donor/edit_profile_provider.dart
// Provider-side Edit Profile page — UI & logic mirror the receiver EditProfilePage.
//
// Usage:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => EditProfileProviderPage(
//       name: currentName,
//       email: currentEmail,
//       phone: currentPhone,
//       address: currentAddress,
//       photoPath: currentPhotoPath, // optional
//     ),
//   ),
// ).then((result) {
//   if (result != null && result is Map<String, dynamic>) {
//     // result contains keys: 'name', 'email', 'phone', 'address', 'photo'
//     // Apply updates (remember the page will return the new value OR an empty string
//     // if the user left the field empty — caller can choose to keep old values).
//   }
// });

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

  @override
  void initState() {
    super.initState();
    // Keep controllers empty so we show placeholders (hintText) instead of pre-filled text.
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    // If caller provided an existing photo path, keep it as preview (but not in the text fields)
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
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  void _saveDetails() {
    // Return a map similar to the receiver page. Caller can decide whether to replace
    // old values with these (we mirror the receiver behavior: if controller is empty,
    // we return the original widget value.)
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

  // Helper to convert a local path to ImageProvider; returns null safely on web or when file missing.
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

  @override
  Widget build(BuildContext context) {
    final accent = Colors.black;
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white, // pure white input boxes (same as receiver)
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Stack(
              children: [
                // avatar — prefer _pickedImage, else try widget.photoPath, else placeholder icon
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _pickedImage != null
                      ? (kIsWeb ? null : FileImage(File(_pickedImage!.path)))
                      : _fileImageProvider(widget.photoPath),
                  child:
                      (_pickedImage == null &&
                          _fileImageProvider(widget.photoPath) == null)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Name field: use hintText with existing value (so it's placeholder-like)
            TextField(
              controller: nameController,
              decoration: inputDecoration.copyWith(
                labelText: 'Name',
                hintText: widget.name.isNotEmpty ? widget.name : 'Enter name',
              ),
            ),
            const SizedBox(height: 20),

            // Email
            TextField(
              controller: emailController,
              decoration: inputDecoration.copyWith(
                labelText: 'Email',
                hintText: widget.email.isNotEmpty
                    ? widget.email
                    : 'Enter email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Phone
            TextField(
              controller: phoneController,
              decoration: inputDecoration.copyWith(
                labelText: 'Phone number',
                hintText: widget.phone.isNotEmpty
                    ? widget.phone
                    : 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Address
            TextField(
              controller: addressController,
              decoration: inputDecoration.copyWith(
                labelText: 'Default Address',
                hintText: widget.address.isNotEmpty
                    ? widget.address
                    : 'Enter default address',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save my details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
