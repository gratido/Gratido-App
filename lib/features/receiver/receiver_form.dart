// lib/features/receiver/receiver_form.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'address_picker.dart';
import 'address_pick_result.dart' show AddressPickResult;

/// If you already have an app theme, reuse your color tokens here.
/// Replace these with your actual brand colors used in receiver registration.
const Color kPrimary = Color(0xFF2A7DE1);
const Color kOnPrimary = Colors.white;
const Color kSurface = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A1A);
const Color kTextSecondary = Color(0xFF6A6A6A);
const Color kDivider = Color(0xFFE6E6E6);
const Color kDisabled = Color(0xFFBDBDBD);

enum ReceiverType { ngo, orphanage, shelter }

class ReceiverFormPage extends StatefulWidget {
  const ReceiverFormPage({Key? key}) : super(key: key);

  @override
  State<ReceiverFormPage> createState() => _ReceiverFormPageState();
}

class _ReceiverFormPageState extends State<ReceiverFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Basic Details Controllers
  ReceiverType? _receiverType;
  final TextEditingController _registeredNameCtrl = TextEditingController();
  final TextEditingController _registeredAddressCtrl = TextEditingController();
  final TextEditingController _beneficiariesCtrl = TextEditingController();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();
  bool _govFunded = false;
  bool _fcra = false;

  // Address from picker
  String? _pickedAddressLine1;
  String? _pickedAddressLine2;
  String? _pickedBuildingDetails;
  LatLng? _pickedLatLng;

  // Documents
  final Map<String, File?> _selectedDocuments = {}; // label -> file

  static const int maxFileBytes = 10 * 1024 * 1024; // 10 MB

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // force rebuild when tab changes so bottom button updates
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _registeredNameCtrl.dispose();
    _registeredAddressCtrl.dispose();
    _beneficiariesCtrl.dispose();
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _aboutCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  List<String> _docLabelsForType(ReceiverType? type) {
    if (type == ReceiverType.ngo) {
      return [
        'Registration certificate',
        'PAN card',
        'Form 12A',
        '80G certificate',
        'Audited financial report',
      ];
    } else if (type == ReceiverType.orphanage) {
      return [
        'Registration certificate',
        'PAN card',
        'Audited financial report',
      ];
    } else if (type == ReceiverType.shelter) {
      return [
        'Local government registration / NGO affiliation letter',
        'PAN card',
        'Basic financial statement',
      ];
    }
    return [];
  }

  bool get _basicDetailsValid {
    return _receiverType != null &&
        _registeredNameCtrl.text.trim().isNotEmpty &&
        (_pickedAddressLine1?.isNotEmpty ?? false) &&
        (_pickedAddressLine2?.isNotEmpty ?? false) &&
        _beneficiariesCtrl.text.trim().isNotEmpty &&
        _fullNameCtrl.text.trim().isNotEmpty &&
        _mobileCtrl.text.trim().length >= 10 &&
        _emailCtrl.text.trim().isNotEmpty &&
        _aboutCtrl.text.trim().isNotEmpty;
  }

  bool get _documentsValid {
    final labels = _docLabelsForType(_receiverType);
    if (labels.isEmpty) return false;
    for (final label in labels) {
      final f = _selectedDocuments[label];
      if (f == null) return false;
      if (!f.existsSync()) return false;
      if (f.lengthSync() > maxFileBytes) return false;
    }
    return true;
  }

  Future<void> _pickDocument(String label) async {
    final result = await FilePicker.platform.pickFiles(
      withData: false,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        final file = File(path);
        final size = await file.length();
        if (size > maxFileBytes) {
          _showSnack('File must be less than 10 MB');
          return;
        }
        setState(() {
          _selectedDocuments[label] = file;
        });
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goToAddressPicker() async {
    final result = await Navigator.of(context).push<AddressPickResult>(
      MaterialPageRoute(
        builder: (_) => AddressPickerPage(
          initialCenter: _pickedLatLng ?? const LatLng(17.447, 78.548),
          initialLine1: _pickedAddressLine1 ??
              '12-1-1/4, Moula Ali Road, Indira Nagar, Malkajgiri',
          initialLine2: _pickedAddressLine2 ?? 'Secunderabad, Telangana, India',
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
        _registeredAddressCtrl.text =
            '${_pickedAddressLine1 ?? ''}\n${_pickedAddressLine2 ?? ''}';
      });
    }
  }

  void _onSubmit() {
    if (!_basicDetailsValid) {
      _showSnack('Please complete all basic details.');
      _tabController.animateTo(0);
      return;
    }
    if (!_documentsValid) {
      _showSnack('Please upload all required documents (under 10 MB).');
      _tabController.animateTo(1);
      return;
    }

    _showSnack('Form ready to submit. Implement backend action here.');
  }

  void _goToNextTab() {
    // As requested: Next should open documents tab when clicked.
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final labels = _docLabelsForType(_receiverType);

    return Scaffold(
      appBar: AppBar(
        // Show back button only on Documents tab (index == 1). No back button on Basic details.
        leading: _tabController.index == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // When back pressed on Documents tab, go to Basic details tab.
                  _tabController.animateTo(0);
                },
              )
            : null,
        title: const Text('Fill application'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Help', style: TextStyle(color: kOnPrimary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          // Text color for both tabs set to black as requested.
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.purple,
          tabs: const [
            Tab(text: 'Basic details'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBasicDetails(), _buildDocuments(labels)],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _tabController.index == 0
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kOnPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _goToNextTab,
                child: const Text('Next'),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_basicDetailsValid && _documentsValid)
                      ? kPrimary
                      : kDisabled,
                  foregroundColor: kOnPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed:
                    (_basicDetailsValid && _documentsValid) ? _onSubmit : null,
                child: const Text('Submit'),
              ),
      ),
    );
  }

  Widget _buildBasicDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Changed as requested
          _sectionTitle('Organisation details'),
          const SizedBox(height: 12),
          _receiverTypeDropdown(),
          const SizedBox(height: 12),
          _textField('Registered name of the NGO', _registeredNameCtrl),
          const SizedBox(height: 12),
          _addressPickerField(),
          const SizedBox(height: 12),
          _numberField('Estimated number of beneficiaries', _beneficiariesCtrl),
          const SizedBox(height: 24),
          _sectionTitle('Your details'),
          const SizedBox(height: 12),
          _textField('Full name', _fullNameCtrl),
          const SizedBox(height: 12),
          _phoneField('Mobile number', _mobileCtrl),
          const SizedBox(height: 12),
          _emailField('Email ID', _emailCtrl),
          const SizedBox(height: 24),
          _sectionTitle('Other details'),
          const SizedBox(height: 12),

          /// FIXED HERE (left as-is)
          _multilineField('About NGO (Mission & Vision)', _aboutCtrl),

          const SizedBox(height: 12),
          _textField(
            'Website link',
            _websiteCtrl,
            helper: 'No website? Add Instagram link',
          ),
          const SizedBox(height: 24),
          _sectionTitle('Funding & registration'),
          const SizedBox(height: 12),
          _binaryChoice(
            'Are you funded by the government?',
            _govFunded,
            (v) => setState(() => _govFunded = v),
          ),
          const SizedBox(height: 12),
          _binaryChoice(
            'Are you registered under FCRA?',
            _fcra,
            (v) => setState(() => _fcra = v),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _receiverTypeDropdown() {
    return _cardField(
      child: DropdownButtonFormField<ReceiverType>(
        value: _receiverType,
        decoration: const InputDecoration(
          labelText: 'Type of receiver',
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: ReceiverType.ngo, child: Text('NGO')),
          DropdownMenuItem(
            value: ReceiverType.orphanage,
            child: Text('Orphanage'),
          ),
          DropdownMenuItem(value: ReceiverType.shelter, child: Text('Shelter')),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: kPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registered address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      display,
                      style: TextStyle(
                        color: (_pickedAddressLine1 == null)
                            ? kTextSecondary
                            : kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocuments(List<String> labels) {
    // Heading should change to "Receiver documents" when user has picked a receiver type
    final heading =
        (_receiverType != null) ? 'Receiver documents' : 'NGO documents';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(heading),
          const SizedBox(height: 8),
          if (_receiverType == null)
            _infoBanner(
              'Select the Type of receiver in Basic details to see required documents.',
            ),
          for (final label in labels) ...[
            _documentRow(label),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          const Divider(color: kDivider),
          const SizedBox(height: 8),
          _submitHint(),
        ],
      ),
    );
  }

  Widget _documentRow(String label) {
    final file = _selectedDocuments[label];
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: kTextSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'File size should be less than 10 MB',
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
                if (file != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    file.path.split(Platform.pathSeparator).last,
                    style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: file == null ? kPrimary : Colors.green,
            ),
            onPressed: () => _pickDocument(label),
          ),
        ],
      ),
    );
  }

  Widget _submitHint() {
    return Row(
      children: const [
        Icon(Icons.lock_outline, size: 18, color: kTextSecondary),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Submit is enabled after all required fields and documents are complete.',
            style: TextStyle(color: kTextSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
      ),
    );
  }

  Widget _cardField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: child,
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    String? helper,
  }) {
    return _cardField(
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          helperText: helper,
        ),
      ),
    );
  }

  Widget _multilineField(String label, TextEditingController ctrl) {
    return _cardField(
      child: TextFormField(
        controller: ctrl,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl) {
    return _cardField(
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _phoneField(String label, TextEditingController ctrl) {
    return _cardField(
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _emailField(String label, TextEditingController ctrl) {
    return _cardField(
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _binaryChoice(String label, bool value, ValueChanged<bool> onChanged) {
    return _cardField(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Yes'),
            selected: value == true,
            onSelected: (_) => onChanged(true),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('No'),
            selected: value == false,
            onSelected: (_) => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: kTextSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: kTextSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
