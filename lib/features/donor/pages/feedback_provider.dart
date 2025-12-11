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
    'General',
    'Bug',
    'Pickup',
    'Provider',
    'Other',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);

    try {
      // 🔥 Upload images to Cloudinary
      final List<Map<String, dynamic>> imageMeta = [];

      for (final file in _pickedFiles) {
        final url = "https://api.cloudinary.com/v1_1/dha5efl8j/image/upload";
        final req = http.MultipartRequest("POST", Uri.parse(url))
          ..fields['upload_preset'] = "gratido_feedback";

        if (file.bytes != null) {
          req.files.add(
            http.MultipartFile.fromBytes('file', file.bytes!,
                filename: file.name),
          );
        } else if (file.path != null) {
          req.files.add(
            await http.MultipartFile.fromPath('file', file.path!),
          );
        }

        final res = await req.send();
        final body = json.decode(await res.stream.bytesToString());

        if (body["secure_url"] != null) {
          imageMeta.add({"name": file.name, "url": body["secure_url"]});
        }
      }

      // 🔥 Save feedback in Firestore
      await FirebaseFirestore.instance.collection('donorFeedback').add({
        'category': _selectedCategory,
        'rating': _rating,
        'message': _messageCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'images': imageMeta,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thanks — your feedback has been sent!'),
          backgroundColor: Colors.green.shade600,
        ),
      );

      _messageCtrl.clear();
      _contactCtrl.clear();
      setState(() {
        _selectedCategory = 'General';
        _rating = 5;
        _pickedFiles = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send feedback: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // (UI below is unchanged)

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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedCategory = c),
          selectedColor: const Color(0xFF6A4CFF),
          backgroundColor: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildRatingRow() {
    final emojis = ['😞', '😕', '👍', '👌', '🔥'];
    final labels = ['Bad', 'Poor', 'Okay', 'Good', 'Great'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final selected = idx == _rating;
        return InkWell(
          onTap: () => setState(() => _rating = idx),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF3EFFF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6A4CFF).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                AnimatedScale(
                  scale: selected ? 1.4 : 1.1,
                  duration: const Duration(milliseconds: 180),
                  child: Text(emojis[i], style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(height: 3),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF6A4CFF)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _pickedFiles = result.files);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_pickedFiles.length} image(s) attached'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6A4CFF);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        centerTitle: true,
        title: const Text(
          'Share feedback',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (UI same)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send us feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tell us what went well or how we can improve. Your feedback helps us make the app better.',
                      style: TextStyle(color: Colors.black54, height: 1.35),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _buildCategoryChips(),
              const SizedBox(height: 14),

              const Text(
                'Rate your experience',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _buildRatingRow(),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 140,
                    maxHeight: 400,
                  ),
                  child: TextField(
                    controller: _messageCtrl,
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration.collapsed(
                      hintText:
                          'Type your message…\n(What happened, where, and when — short and clear helps)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: TextField(
                        controller: _contactCtrl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Optional: your email or phone (so we can follow up)',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _pickImages,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.attach_file, color: Colors.grey.shade700),
                          const SizedBox(height: 4),
                          Text(
                            'Attach',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_sending || _messageCtrl.text.trim().isEmpty)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _sending ? 0 : 6,
                      ),
                      child: _sending
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Sending...',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            )
                          : const Text(
                              'Send feedback',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'We read every message and reply when follow-up is needed.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
