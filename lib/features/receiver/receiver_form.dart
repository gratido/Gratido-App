// lib/features/receiver/receiver_form.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import 'address_picker.dart';
import 'address_pick_result.dart' show AddressPickResult;
import 'dart:convert'; // ✅ Fixes 'jsonEncode' error
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Fixes 'Supabase' error
import 'package:http/http.dart' as http; // ✅ Required for backend API call
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Required for Token retrieval

/// 💜 GRATIDO COLOR TOKENS

const Color kAccentViolet = Color(0xFF6A4CFF);
const Color kCardWhite = Colors.white;

const Color kTextPrimary = Colors.black87;
const Color kTextSecondary = Colors.black54;
const Color kMutedText = Color(0xFF757575);

const Color kDisabled = Color(0xFFD6D1F5);

const LinearGradient kGratidoGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFF3EFFF),
    Color(0xFFE9E4FF),
  ],
);

enum ReceiverType {
  ngo,
  orphanage,
  shelter,
  general, // General (public)
}

class ReceiverFormPage extends StatefulWidget {
  const ReceiverFormPage({Key? key}) : super(key: key);

  @override
  State<ReceiverFormPage> createState() => _ReceiverFormPageState();
}

class _ReceiverFormPageState extends State<ReceiverFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ReceiverType? _receiverType;

  final TextEditingController _registeredNameCtrl = TextEditingController();
  final TextEditingController _beneficiariesCtrl = TextEditingController();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();

  String? _pickedAddressLine1;
  String? _pickedAddressLine2;
  String? _pickedBuildingDetails;
  LatLng? _pickedLatLng;

  final Map<String, File?> _selectedDocuments = {};

  static const int maxFileBytes = 10 * 1024 * 1024;

  bool get _isGeneralPublic => _receiverType == ReceiverType.general;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _registeredNameCtrl.dispose();
    _beneficiariesCtrl.dispose();
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _aboutCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // ---------------- VALIDATION ----------------

  bool get _basicDetailsValid {
    if (_isGeneralPublic) {
      return _fullNameCtrl.text.trim().isNotEmpty &&
          _mobileCtrl.text.trim().length >= 10 &&
          _emailCtrl.text.trim().isNotEmpty &&
          (_pickedAddressLine1?.isNotEmpty ?? false) &&
          (_pickedAddressLine2?.isNotEmpty ?? false);
    }

    return _receiverType != null &&
        _registeredNameCtrl.text.trim().isNotEmpty &&
        _beneficiariesCtrl.text.trim().isNotEmpty &&
        _fullNameCtrl.text.trim().isNotEmpty &&
        _mobileCtrl.text.trim().length >= 10 &&
        _emailCtrl.text.trim().isNotEmpty &&
        _aboutCtrl.text.trim().isNotEmpty &&
        (_pickedAddressLine1?.isNotEmpty ?? false) &&
        (_pickedAddressLine2?.isNotEmpty ?? false);
  }

  bool get _documentsValid {
    final labels = _docLabelsForType(_receiverType);
    if (labels.isEmpty) return false;

    for (final label in labels) {
      final f = _selectedDocuments[label];
      if (f == null || !f.existsSync() || f.lengthSync() > maxFileBytes) {
        return false;
      }
    }
    return true;
  }

  // ---------------- DOCUMENT LOGIC ----------------

  List<String> _docLabelsForType(ReceiverType? type) {
    if (type == ReceiverType.general) return ['Aadhaar card'];

    if (type == ReceiverType.ngo) {
      return [
        'Registration certificate',
        'PAN card',
        'Form 12A',
        '80G certificate',
        'Audited financial report',
      ];
    }

    if (type == ReceiverType.orphanage) {
      return [
        'Registration certificate',
        'PAN card',
        'Audited financial report',
      ];
    }

    if (type == ReceiverType.shelter) {
      return [
        'Local government registration / NGO affiliation letter',
        'PAN card',
        'Basic financial statement',
      ];
    }

    return [];
  }

  // ---------------- ACTIONS ----------------

  Future<void> _pickDocument(String label) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        final file = File(path);
        if (await file.length() > maxFileBytes) {
          _showSnack('File must be less than 10 MB');
          return;
        }
        setState(() => _selectedDocuments[label] = file);
      }
    }
  }

  void _goToAddressPicker() async {
    final result = await Navigator.of(context).push<AddressPickResult>(
      MaterialPageRoute(
        builder: (_) => AddressPickerPage(
          initialCenter: _pickedLatLng ?? const LatLng(17.447, 78.548),
          initialLine1: _pickedAddressLine1 ?? '',
          initialLine2: _pickedAddressLine2 ?? '',
          initialBuilding: _pickedBuildingDetails ?? '',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedLatLng = result.position;
        _pickedAddressLine1 = result.addressLine1;
        _pickedAddressLine2 = result.addressLine2;
        _pickedBuildingDetails = result.buildingDetails;
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ SENIOR FIX: UPLOADS DOCUMENTS AND CALLS BACKEND 🚀
  // ✅ SENIOR FIX: INTEGRATED SUBMISSION WITH STORAGE & BACKEND 🚀
  Future<void> _onSubmit() async {
    if (!_basicDetailsValid) {
      _showSnack('Please complete all details.');
      _tabController.animateTo(0);
      return;
    }
    if (!_documentsValid) {
      _showSnack('Please upload required documents.');
      _tabController.animateTo(1);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final List<String> uploadedUrls = [];

      // 1. 📤 Upload to 'ngo-documents' bucket
      for (var entry in _selectedDocuments.entries) {
        if (entry.value != null) {
          final fileName =
              'NGO_${DateTime.now().millisecondsSinceEpoch}_${entry.key.replaceAll(' ', '_')}.jpg';

          await supabase.storage
              .from('receiver-documents')
              .upload(fileName, entry.value!);

          final String publicUrl = supabase.storage
              .from('receiver-documents')
              .getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      // 2. 🔑 Get Auth Token
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      // 3. 🚀 Call C# Backend (Using 192.168.0.4)
      final registrationData = {
        "organizationName":
            _isGeneralPublic ? _fullNameCtrl.text : _registeredNameCtrl.text,
        "organizationType": _receiverType.toString().split('.').last,
        "description": _aboutCtrl.text,
        "address": "$_pickedAddressLine1, $_pickedAddressLine2",
        "latitude": _pickedLatLng?.latitude ?? 17.447,
        "longitude": _pickedLatLng?.longitude ?? 78.548,
        "documentUrls": uploadedUrls,
      };

      final response = await http.post(
        Uri.parse('http://192.168.0.4:5227/api/Receiver/register-ngo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registrationData),
      );

      if (response.statusCode == 200) {
        _showSnack('Submitted! Waiting for Admin verification.');
        Navigator.of(context).pushReplacementNamed('/receiver');
      } else {
        throw Exception("Server Error: ${response.body}");
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ---------------- UI ROOT ----------------

  @override
  Widget build(BuildContext context) {
    final labels = _docLabelsForType(_receiverType);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: kGratidoGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              TabBar(
                controller: _tabController,
                labelColor: kAccentViolet,
                unselectedLabelColor: kTextSecondary,
                indicatorColor: kAccentViolet,
                tabs: const [
                  Tab(text: 'Basic details'),
                  Tab(text: 'Documents'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicDetails(),
                    _buildDocuments(labels),
                  ],
                ),
              ),
              _bottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: _tabController.index == 1
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: kTextPrimary),
              onPressed: () => _tabController.animateTo(0),
            )
          : null,
      title: const Text(
        'Fill application',
        style: TextStyle(color: kTextPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Help',
            style: TextStyle(color: kAccentViolet),
          ),
        ),
      ],
    );
  }

  // ---------------- BOTTOM BUTTON ----------------

  Widget _bottomButton() {
    final isSubmit = _tabController.index == 1;
    final enabled = isSubmit ? (_basicDetailsValid && _documentsValid) : true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? kAccentViolet : kDisabled,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: enabled
            ? (isSubmit ? _onSubmit : () => _tabController.animateTo(1))
            : null,
        child: Text(isSubmit ? 'Submit' : 'Next'),
      ),
    );
  }

  // ---------------- BASIC DETAILS ----------------

  Widget _buildBasicDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Organisation details'),
        const SizedBox(height: 12),
        _receiverTypeDropdown(),
        const SizedBox(height: 12),
        _textField('Registered name of the Organisation', _registeredNameCtrl,
            disabled: _isGeneralPublic),
        const SizedBox(height: 12),
        _numberField('Estimated number of beneficiaries', _beneficiariesCtrl,
            disabled: _isGeneralPublic),
        const SizedBox(height: 24),
        _sectionTitle('Address'),
        const SizedBox(height: 12),
        _addressPickerField(),
        const SizedBox(height: 24),
        _sectionTitle('Personal details'),
        const SizedBox(height: 12),
        _textField('Full name', _fullNameCtrl),
        const SizedBox(height: 12),
        _phoneField('Mobile number', _mobileCtrl),
        const SizedBox(height: 12),
        _emailField('Email ID', _emailCtrl),
        const SizedBox(height: 24),
        _sectionTitle('Other details'),
        const SizedBox(height: 12),
        _multilineField('About Organisation (Mission & Vision)', _aboutCtrl,
            disabled: _isGeneralPublic),
        const SizedBox(height: 12),
        _textField('Website link', _websiteCtrl,
            helper: 'No website? Add Instagram link',
            disabled: _isGeneralPublic),
      ]),
    );
  }

  // ---------------- DOCUMENTS ----------------

  Widget _buildDocuments(List<String> labels) {
    final heading = _receiverType == ReceiverType.general
        ? 'Identity document'
        : (_receiverType != null ? 'Receiver documents' : 'NGO documents');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(heading),
        const SizedBox(height: 8),
        for (final label in labels) ...[
          _documentRow(label),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }

  // ---------------- COMMON WIDGETS ----------------

  Widget _cardField({required Widget child, bool disabled = false}) {
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          decoration: BoxDecoration(
            color: kCardWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }

  Widget _receiverTypeDropdown() {
    return _cardField(
      child: DropdownButtonFormField<ReceiverType>(
        value: _receiverType,
        decoration: const InputDecoration(
            labelText: 'Type of receiver', border: InputBorder.none),
        items: const [
          DropdownMenuItem(value: ReceiverType.ngo, child: Text('NGO')),
          DropdownMenuItem(
              value: ReceiverType.orphanage, child: Text('Orphanage')),
          DropdownMenuItem(value: ReceiverType.shelter, child: Text('Shelter')),
          DropdownMenuItem(
              value: ReceiverType.general, child: Text('General (public)')),
        ],
        onChanged: (val) {
          setState(() {
            _receiverType = val;
            _selectedDocuments.clear();
          });
        },
      ),
    );
  }

  Widget _addressPickerField() {
    final display = (_pickedAddressLine1 != null && _pickedAddressLine2 != null)
        ? '${_pickedAddressLine1!}\n${_pickedAddressLine2!}'
        : 'Tap to select address on map';

    return _cardField(
      child: InkWell(
        onTap: _goToAddressPicker,
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: kAccentViolet),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Registered address',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: kTextPrimary)),
              const SizedBox(height: 6),
              Text(display,
                  style: TextStyle(
                      color: _pickedAddressLine1 == null
                          ? kTextSecondary
                          : kTextPrimary)),
            ]),
          ),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }

  Widget _documentRow(String label) {
    final file = _selectedDocuments[label];
    return _cardField(
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: kTextPrimary)),
            const SizedBox(height: 4),
            const Text('File size should be less than 10 MB',
                style: TextStyle(fontSize: 12, color: kTextSecondary)),
            if (file != null)
              Text(file.path.split(Platform.pathSeparator).last,
                  style: const TextStyle(fontSize: 12, color: kTextSecondary)),
          ]),
        ),
        IconButton(
          icon: Icon(file == null ? Icons.upload_file : Icons.check_circle,
              color: file == null ? kAccentViolet : Colors.green),
          onPressed: () => _pickDocument(label),
        )
      ]),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary));

  Widget _textField(String label, TextEditingController ctrl,
      {String? helper, bool disabled = false}) {
    return _cardField(
      disabled: disabled,
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
            labelText: label, helperText: helper, border: InputBorder.none),
      ),
    );
  }

  Widget _multilineField(String label, TextEditingController ctrl,
      {bool disabled = false}) {
    return _cardField(
      disabled: disabled,
      child: TextFormField(
        controller: ctrl,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl,
      {bool disabled = false}) {
    return _cardField(
      disabled: disabled,
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _phoneField(String label, TextEditingController ctrl) =>
      _textField(label, ctrl);

  Widget _emailField(String label, TextEditingController ctrl) =>
      _textField(label, ctrl);
}
