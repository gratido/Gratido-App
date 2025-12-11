// lib/features/donor/add_donations/add_donations.dart
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'controllers/contact_controller.dart';
import 'controllers/food_controller.dart';
import 'donor_widgets/donor_widgets.dart';
import '../map_picker.dart';
import '../donation_repo.dart';
import '../donor_listing.dart';

class AddDonationsScreen extends StatefulWidget {
  const AddDonationsScreen({super.key});

  @override
  State<AddDonationsScreen> createState() => _AddDonationsScreenState();
}

class _AddDonationsScreenState extends State<AddDonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContactController _contact = ContactController();
  final FoodController _food = FoodController();
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Block tapping “Food details” unless contact is valid
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          !(_contactFormKey.currentState?.validate() ?? false)) {
        // prevent switching — do NOT show snackbar (validation shown inline)
        _tabController.index = 0;
      }
    });

    _contact.loadSavedContact(); // autofill if saved
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contact.dispose();
    _food.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    final contactValid =
        _contact.donorController.text.trim().isNotEmpty &&
        _contact.phoneController.text.trim().length >= 10 &&
        _contact.pickupController.text.trim().isNotEmpty;

    final foodValid = _food.isValid;

    if (!contactValid || !foodValid) {
      // do not show snackbars per request — validators will show inline
      return;
    }

    // Save contact details
    await _contact.saveContact();

    // Add donation to repo so it shows in Listing/MyDonations
    final donation = Donation(
      donorName: _contact.donorController.text.trim(),
      phone: "+91 ${_contact.phoneController.text.trim()}",
      pickupLocation: _contact.pickupController.text.trim(),
      pickupWindow: _food.pickupWindow == 'Other'
          ? 'Other'
          : (_food.pickupWindow ?? 'ASAP'),
      pickupWindowOther: _food.pickupWindow == 'Other'
          ? _food.pickupWindowOther
          : null,
      category: _food.category ?? 'Cooked Meals',
      foodName: _food.foodName?.trim(), // <-- NEW: save Food Name
      quantity: _food.quantity,
      photoPaths: List<String>.from(_food.photoPaths),
      hygieneConfirmed: _food.hygieneConfirmed,
      preparedTime: _food.preparedSelected,
      expiryTime: _food.expiryTime,
      notes: _food.notes,
      isNew: true,
    );

    DonationRepo.instance.addDonation(donation);

    // Reset food details but keep contact info
    _food.reset();

    // Show a small modern dialog; on OK navigate to Donation Listings
    await showDialog(
      context: context,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Donation submitted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your donation has been posted successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(c).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Navigate to Donation Listings page
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const DonorListing()));
  }

  Future<TimeOfDay?> _pickTime() async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  void _goToFoodTab() {
    if (_contactFormKey.currentState?.validate() ?? false) {
      _tabController.animateTo(1);
    } else {
      // no snackbars — inline validators are visible
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _contact.pickupController.text = result.trim();
      });
    }
  }

  Future<void> _resetContactDetails() async {
    await _contact.resetContact();
    // do NOT show snackbars (per request). keep UI updated
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("Donate"),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            // Block manual tap to Food tab unless contact is valid
            if (index == 1 &&
                !(_contactFormKey.currentState?.validate() ?? false)) {
              _tabController.index = 0;
            }
          },
          tabs: const [
            Tab(text: "Contact"),
            Tab(text: "Food details"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            children: [
              Expanded(
                child: ContactSection(
                  controller: _contact,
                  formKey: _contactFormKey,
                  onContinue: _goToFoodTab,
                  openMapPicker: _openMapPicker,
                  onEditAccount: _resetContactDetails,
                ),
              ),
            ],
          ),
          FoodSection(
            food: _food,
            contact: _contact,
            pickTime: _pickTime,
            onSubmit: _submitDonation,
          ),
        ],
      ),
    );
  }
}
