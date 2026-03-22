import 'package:flutter/material.dart';
import 'controllers/contact_controller.dart';
import 'controllers/food_controller.dart';
import 'donor_widgets/donor_widgets.dart';
import '../map_picker.dart';
import '../myDonations.dart';

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
  double? _pickedLat;
  double? _pickedLng;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        final formValid = _contactFormKey.currentState?.validate() ?? false;
        final pickupValid = _contact.pickupController.text.trim().isNotEmpty;

        if (!formValid || !pickupValid) {
          _tabController.index = 0;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
  await _contact.loadSavedContact();
  setState(() {});
});
  }

  bool _isContactValid() {
    final formValid = _contactFormKey.currentState?.validate() ?? false;
    final pickupValid = _contact.pickupController.text.trim().isNotEmpty;
    return formValid && pickupValid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contact.dispose();
    _food.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Now fetches real phone and address from UI and sends to backend
// ✅ EXCITED UPDATE: THIS TRIGGERS YOUR PURPLE POPUP & CAPTURES MANUAL PHONE!
  // ✅ SENIOR FIX: ULTIMATE SYNC — ORIGINAL UI + REAL BACKEND LOGIC! 🚀
  // ✅ SENIOR FIX: ULTIMATE SYNC — ORIGINAL UI + REAL BACKEND LOGIC! 🚀
  Future<void> _submitDonation() async {
    // 1. Check local UI validation
    final contactValid = _contact.donorController.text.trim().isNotEmpty &&
        _contact.phoneController.text.trim().length >= 10 &&
        _contact.pickupController.text.trim().isNotEmpty;

    final foodValid = _food.isValid;

    if (!contactValid || !foodValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required fields correctly")),
      );
      return;
    }

    // 2. Fetch the REAL data you typed manually!
    final String realPhone = _contact.phoneController.text.trim();
    final String realAddress = _contact.pickupController.text.trim();

    // 🚀 3. CALL REAL BACKEND (Passing the manual strings to our fixed controller)
    final bool success =
        await _food.submitDonation(context, realPhone, realAddress);

    if (success) {
      // ✅ 4. BOOM! SHOW YOUR ORIGINAL BEAUTIFUL PURPLE SUCCESS DIALOG!
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.25),
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  padding: const EdgeInsets.fromLTRB(22, 48, 22, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6E5CD6).withOpacity(.28),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Donation submitted",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Your donation has been posted successfully.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E5CD6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 6,
                            shadowColor:
                                const Color(0xFF6E5CD6).withOpacity(.45),
                          ),
                          child: const Text(
                            "OK",
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

                // Floating check icon (Your original beautiful design)
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6E5CD6),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          );
        },
      );

      // ✅ 5. RESET AND NAVIGATE
      _food.reset();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyDonations()));
    } else {
      // ❗ ERROR HANDLING: Alerts you if the port 5227 or IP is blocked!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Submission failed. Check Laptop IP and Firewall!")),
      );
    }
  }

  Future<TimeOfDay?> _pickTime() async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  Future<void> _goToFoodTab() async {
  FocusScope.of(context).unfocus(); // commit text

  if (_isContactValid()) {
    await _contact.saveContact();   // ✅ SAVE HERE
    _tabController.animateTo(1);
  }
}

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null && result.trim().isNotEmpty) {
  _contact.pickupController.text = result.trim();
  setState(() {});
}
  }
  Future<void> _resetContactDetails() async {
    await _contact.resetContact();
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x1A6E5CD6),
              Color(0x00FFFFFF),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Donate"),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6E5CD6),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF6E5CD6),
              onTap: (index) {
                if (index == 1 && !_isContactValid()) {
                  _tabController.index = 0;
                }
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.person_outline),
                  text: "Contact",
                ),
                Tab(
                  icon: Icon(Icons.restaurant_menu),
                  text: "Food details",
                ),
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
                onSubmit: _submitDonation, // ✅ Triggers the real backend logic
              ),
            ],
          ),
        ),
      ),
    );
  }
}