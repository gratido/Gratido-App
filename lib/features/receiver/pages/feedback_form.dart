// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _messageCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _selectedCategory = 'General';
  int _rating = 5;
  bool _sending = false;

  List<PlatformFile> _pickedFiles = [];

  final List<String> _categories = [
    'Food Quality',
    'Packaging',
    'Quantity',
    'App Experience',
    'Others',
  ];

  static const Color primary = Color(0xFF6E5CD6);
  static const Color bgSoft = Color(0xFFF7F3FF);

  @override
  void dispose() {
    _messageCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  // ---------------- SUCCESS POPUP ----------------

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 36),
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  width: MediaQuery.of(context).size.width * 0.82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Thank you!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your feedback helps us improve and serve better.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.45),
                        blurRadius: 22,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- IMAGE PREVIEW ----------------

  Widget _buildImagePreview() {
    if (_pickedFiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _pickedFiles.map((file) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              image: file.bytes != null
                  ? MemoryImage(file.bytes!)
                  : FileImage(File(file.path!)) as ImageProvider,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    setState(() => _sending = true);

    try {
      final List<Map<String, dynamic>> imageMeta = [];

      for (final file in _pickedFiles) {
        final req = http.MultipartRequest(
          "POST",
          Uri.parse("https://api.cloudinary.com/v1_1/dha5efl8j/image/upload"),
        )..fields['upload_preset'] = "gratido_feedback";

        if (file.bytes != null) {
          req.files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
            ),
          );
        } else {
          req.files.add(
            await http.MultipartFile.fromPath('file', file.path!),
          );
        }

        final res = await req.send();
        final body = json.decode(await res.stream.bytesToString());

        if (body["secure_url"] != null) {
          imageMeta.add({
            "name": file.name,
            "url": body["secure_url"],
          });
        }
      }

      await FirebaseFirestore.instance.collection('donorFeedback').add({
        'category': _selectedCategory,
        'rating': _rating,
        'message': _messageCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'images': imageMeta,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessPopup();

      _messageCtrl.clear();
      _contactCtrl.clear();

      setState(() {
        _selectedCategory = 'General';
        _rating = 5;
        _pickedFiles = [];
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ---------------- CATEGORY ----------------

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((c) {
        final isSelected = c == _selectedCategory;
        return ChoiceChip(
          label: Text(
            c,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedColor: primary,
          checkmarkColor: Colors.white, // ✅ WHITE TICK
          onSelected: (_) => setState(() => _selectedCategory = c),
        );
      }).toList(),
    );
  }

  // ---------------- RATING (EMOJIS) ----------------

  Widget _buildRatingRow() {
    final emojis = ['😞', '😕', '👍', '👌', '🔥'];
    final labels = ['Bad', 'Poor', 'Okay', 'Good', 'Great'];

    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        final selected = idx == _rating;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 4 ? 0 : 8),
            child: InkWell(
              onTap: () => setState(() => _rating = idx),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF1EDFF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color.fromARGB(255, 120, 97, 248)
                                .withOpacity(0.75),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emojis[i],
                      style: const TextStyle(fontSize: 22), // reduced
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11, // reduced
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? const Color.fromARGB(255, 108, 85, 243)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------- PICK IMAGES ----------------

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() => _pickedFiles = result.files);
    }
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final bool canSend = _messageCtrl.text.trim().isNotEmpty && !_sending;

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: const Text('Share feedback',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E3FF),
              Color(0xFFF7F3FF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCard(),
              const SizedBox(height: 16),
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              const Text('Rate your experience',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _buildRatingRow(),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(minHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _messageCtrl,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contactCtrl,
                      decoration: InputDecoration(
                        hintText: 'Optional: your email or phone',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.attach_file),
                  ),
                ],
              ),
              _buildImagePreview(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSend ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSend ? primary : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _sending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'We read every message and reply when follow-up is needed.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send us feedback',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Tell us what went well or how we can improve. Your feedback helps us make the app better.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
