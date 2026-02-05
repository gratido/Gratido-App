// lib/features/donor/add_donations/donor_widgets/donor_widgets.dart
// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/contact_controller.dart';
import '../controllers/food_controller.dart';

const Color kPrimary = Color(0xFF6E5CD6);

BoxDecoration _boxDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF6E5CD6).withOpacity(0.085),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

/// ------------------------------
/// CONTACT SECTION (unchanged logic, header moved)
/// ------------------------------
class ContactSection extends StatelessWidget {
  final ContactController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onContinue;
  final Future<void> Function() openMapPicker;

  /// NEW: optional callback for the top-right Edit button
  final VoidCallback? onEditAccount;

  const ContactSection({
    super.key,
    required this.controller,
    required this.formKey,
    required this.onContinue,
    required this.openMapPicker,
    this.onEditAccount, // optional: if provided, shows "Edit" button at top-right
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Base purple gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF1EEFF), // stronger lavender tint
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          // Actual content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Contact info",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (onEditAccount != null)
                        TextButton(
                          onPressed: onEditAccount,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6E5CD6),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          child: const Text("Edit"),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _fieldLabel("Full name / Organization"),
                  const SizedBox(height: 8),
                  _styledInput(
                    controller: controller.donorController,
                    hint: "Enter your full name",
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: 20),
                  _fieldLabel("Phone number"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: _boxDecoration(),
                        child: Row(
                          children: const [
                            Text("🇮🇳", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 6),
                            Text(
                              "+91",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _styledInput(
                          controller: controller.phoneController,
                          hint: "Enter your number",
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().length < 10)
                              ? 'Invalid number'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _fieldLabel("Pickup location"),
                  const SizedBox(height: 8),

                  FormField<String>(
                    validator: (_) {
                      if (controller.pickupController.text.trim().isEmpty) {
                        return 'Pickup location is required';
                      }
                      return null;
                    },
                    builder: (state) {
                      final hasError = state.hasError;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              await openMapPicker();
                              state.didChange(controller.pickupController.text);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: _boxDecoration().copyWith(
                                border: hasError
                                    ? Border.all(
                                        color: Colors.red.shade400,
                                      )
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.pickupController.text.isEmpty
                                          ? "Tap to pick from map"
                                          : controller.pickupController.text,
                                      style: TextStyle(
                                        color: controller
                                                .pickupController.text.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.map_outlined,
                                    color: kPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (hasError) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E5CD6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String t) =>
      Text(t, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _styledInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// FOOD SECTION START (unchanged)
/// ------------------------------
class FoodSection extends StatefulWidget {
  final FoodController food;
  final ContactController contact;
  final Future<TimeOfDay?> Function() pickTime;
  final Future<void> Function() onSubmit;

  const FoodSection({
    super.key,
    required this.food,
    required this.contact,
    required this.pickTime,
    required this.onSubmit,
  });

  @override
  State<FoodSection> createState() => _FoodSectionState();
}

class _FoodSectionState extends State<FoodSection> {
  final TextEditingController _foodNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foodNameCtrl.text = widget.food.foodName ?? "";
  }

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _showMaxPhotoDialog() async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 32,
                          color: kPrimary,
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Maximum photos reached",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "You can upload up to 5 photos only",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF6E5CD6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6E5CD6).withOpacity(.22),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddPhoto() async {
    final added = await widget.food.pickImage();
    if (!added && widget.food.photoPaths.length >= FoodController.maxPhotos) {
      await _showMaxPhotoDialog();
    }
  }

  Widget _purchaseFreshnessOptions(FoodController food) {
    const options = ["Today", "Yesterday", "3–4 days ago"];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = food.freshness == opt;

        return GestureDetector(
          onTap: () {
            food.setFreshness(opt);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kPrimary : Colors.white,
              border: Border.all(
                color: selected ? kPrimary : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: kPrimary.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

// ------------------------------
// CARD SECTION WRAPPER
// ------------------------------
  Widget _cardSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Food details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // UPDATED: label changed from "What food is it?" to "Food name"
            _fieldLabel("Food name"),
            const SizedBox(height: 8),
            _styledInputFood(
              controller: _foodNameCtrl,
              hint: "Enter the food name",
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  food.setFoodName("");
                } else {
                  food.setFoodName(v);
                }
              },
            ),

            // REMOVED the explicit outer label and using a single label inside styledDropdown
            styledDropdown(
              label: "Category",
              value: food.category,
              items: food.categories,
              onChanged: (v) {
                food.setCategory(v);
                setState(() {});
              },
            ),

// 👇👇👇 PASTE THIS BLOCK RIGHT HERE 👇👇👇
            const SizedBox(height: 20),

            _cardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (food.category == 'Fruits' ||
                      food.category == 'Vegetables') ...[
                    _fieldLabel("When was the item purchased?"),
                    const SizedBox(height: 12),
                    _purchaseFreshnessOptions(food),
                  ] else ...[
                    _fieldLabel("When was this food prepared?"),
                    const SizedBox(height: 12),
                    _preparedButtons(food),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            _fieldLabel("Food expiry date"),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DateTime tempSelected = food.expiryDateObj ?? DateTime.now();

                final picked = await showDialog<DateTime>(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.4),
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                      child: StatefulBuilder(
                        builder: (context, setLocalState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 12, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "SELECT DATE",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${_weekday(tempSelected)}, "
                                          "${_month(tempSelected)} "
                                          "${tempSelected.day}",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFF6E5CD6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(height: 1),

                              // Calendar
                              CalendarDatePicker(
                                initialDate: tempSelected,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 6),
                                onDateChanged: (date) {
                                  setLocalState(() {
                                    tempSelected = date;
                                  });
                                },
                              ),

                              // Footer buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "CANCEL",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, tempSelected),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Color(0xFF6E5CD6),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );

                if (picked != null) {
                  food.setExpiryDate(picked);
                  FocusScope.of(context).unfocus();
                  setState(() {});
                }
              },
              child: Container(
                decoration: _boxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.expiryTime ?? "Pick the food expiry date",
                        style: TextStyle(
                          color: food.expiryTime == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: kPrimary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),
            styledDropdown(
              label: "Preferred pickup window",
              value: food.pickupWindow,
              items: food.pickupWindowOptions,
              onChanged: (v) {
                food.setPickupWindow(v);
                setState(() {});
              },
            ),

            const SizedBox(height: 12),

            // If "Other" show a time picker row
            if (food.pickupWindow == 'Other')
              InkWell(
                onTap: () async {
                  final picked = await widget.pickTime();
                  if (picked != null) {
                    food.setPickupOther(picked);
                    setState(() {});
                  }
                },
                child: Container(
                  decoration: _boxDecoration(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (food.pickupWindowOther?.isNotEmpty ?? false)
                              ? food.pickupWindowOther!
                              : "Pick a custom time",
                          style: TextStyle(
                            color: (food.pickupWindowOther?.isNotEmpty ?? false)
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const Icon(Icons.access_time, color: kPrimary),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
            _fieldLabel("Quantity (persons)"),
            const SizedBox(height: 8),

            Container(
              decoration: _boxDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  if (v.trim().isEmpty) {
                    food.setQuantity(0); // invalidate immediately
                  } else {
                    final val = int.tryParse(v);
                    if (val != null) food.setQuantity(val);
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Enter number of persons",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),
            _fieldLabel("Photos (take at least one)"),
            const SizedBox(height: 8),
            _photoRow(food),

            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: food.hygieneConfirmed,
                  onChanged: (v) {
                    food.setHygiene(v ?? false);
                    setState(() {});
                  },
                ),
                const Expanded(
                  child: Text(
                    "I confirm the food is fresh, packed, and safe for pickup",
                  ),
                ),
              ],
            ),

            // UPDATED: caution box with a modern icon chip (keeps original text)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.report_problem_rounded,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Avoid donating half-eaten or yesterday’s food. Keep items covered until pickup.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    food.isValid ? () async => await widget.onSubmit() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: food.isValid ? kPrimary : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(DateTime d) {
    const days = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];
    return days[d.weekday % 7];
  }

  String _month(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[d.month - 1];
  }

  /// ------------------------------
  /// Helper methods
  /// ------------------------------
  Widget _fieldLabel(String t) =>
      Text(t, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _styledInputFood({
    required TextEditingController controller,
    required String hint,
    required void Function(String) onChanged,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Enter the food name",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget styledDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        FocusScope(
          node: FocusScopeNode(), // ← stops keyboard jump
          child: Builder(
            builder: (context) {
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  FocusManager.instance.primaryFocus
                      ?.unfocus(); // kill keyboard

                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset pos = box.localToGlobal(Offset.zero);
                  final Size size = box.size;

                  final selected = await showMenu<String>(
                    context: context,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    position: RelativeRect.fromLTRB(
                      pos.dx,
                      pos.dy + size.height + 8,
                      pos.dx + size.width,
                      0,
                    ),
                    items: items.map((item) {
                      final isSelected = item == value;

                      return PopupMenuItem<String>(
                        value: item,
                        height: 54,
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          splashColor: kPrimary.withOpacity(0.08),
                          highlightColor: kPrimary.withOpacity(0.06),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFFF5F3FF) // light purple background
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color:
                                        isSelected ? kPrimary : Colors.black87,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check,
                                      size: 18, color: kPrimary),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );

                  if (selected != null) onChanged(selected);
                },
                child: Container(
                  width: double.infinity,
                  decoration: _boxDecoration(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value ?? "Select $label",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.expand_more, color: kPrimary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _photoRow(FoodController food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: food.photoPaths.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (c, i) {
              if (i == food.photoPaths.length) {
                return _addPhotoTile();
              }

              final path = food.photoPaths[i];

              Widget img;
              if (path.startsWith('assets/')) {
                img = Image.asset(path, fit: BoxFit.cover);
              } else {
                final file = File(path);
                if (!file.existsSync()) {
                  img = Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                } else {
                  img = Image.file(file, fit: BoxFit.cover);
                }
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade100,
                      child: img,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        food.removeImage(i);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              if (food.photoPaths.length >= FoodController.maxPhotos) {
                await _showMaxPhotoDialog();
                return;
              }
              await _handleAddPhoto();
              setState(() {});
            },
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text("Take photo (required)"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoTile() {
    return GestureDetector(
      onTap: () async {
        if (widget.food.photoPaths.length >= FoodController.maxPhotos) {
          await _showMaxPhotoDialog();
          return;
        }
        await _handleAddPhoto();
        setState(() {});
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 32, color: Colors.grey),
        ),
      ),
    );
  }

  // Prepared time segmented buttons
  // Prepared time segmented buttons
  Widget _preparedButtons(FoodController food) {
    final options = food.preparedOptions;

    // 🔒 Disable when Packed Food selected
    final bool isPackedFood = food.category == 'Packed Food';

    return IgnorePointer(
      ignoring: isPackedFood, // blocks taps
      child: Opacity(
        opacity: isPackedFood ? 0.45 : 1.0, // visual disabled effect
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // always 2 in a row
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (_, i) {
            final opt = options[i];
            final selected = food.preparedSelected == opt;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                food.setPrepared(opt);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: kPrimary.withOpacity(.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14, // tighter fit like you wanted
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
