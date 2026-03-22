// ignore_for_file: use_super_parameters, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'receiver_detail.dart';

// ✅ NEW IMPORTS
import 'models/food_item.dart';
import 'models/dummy_food_repo.dart';
import 'package:http/http.dart' as http;

const Color primary = Color(0xFF6E5CD6);

class ReceiverListingsPage extends StatefulWidget {
  final bool isVerified; // ✅ NEW
  final double lat; // ✅ NEW
  final double lng;
  const ReceiverListingsPage({
    Key? key,
    this.isVerified = false,
    this.lat = 0.0, // Default to 0 if not passed
    this.lng = 0.0,
  }) : super(key: key);
  @override
  State<ReceiverListingsPage> createState() => _ReceiverListingsPageState();
}

class _ReceiverListingsPageState extends State<ReceiverListingsPage> {
  late List<FoodItem> _items;
  final Map<String, String> _statusMap = {};
  bool _isLoading = true; // ✅ Track loading state

  @override
  void initState() {
    super.initState();
    // 1. Start with samples
    _items = DummyFoodRepo.getFoodItems();
    for (final item in _items) {
      _statusMap[item.id.toString()] = 'open';
    }

    // 2. Fetch real data and add it to the list
    _fetchRealItems();
  }

  Future<void> _fetchRealItems() async {
    const String laptopIp = "192.168.0.5"; // Your consistent IP
    try {
      debugPrint("LIST LAT: ${widget.lat}, LNG: ${widget.lng}");
      final response = await http.get(
        Uri.parse(
            'http://$laptopIp:5227/api/Donation/nearby?lat=${widget.lat}&lng=${widget.lng}&radius=15'),
      );
      debugPrint("API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];

        // Convert json to FoodItem objects
        final realItems = data.map((json) => FoodItem.fromJson(json)).toList();

        setState(() {
          // 🚀 THE MAGIC: Combine Samples + Real Data
          _items.addAll(realItems);

          // Ensure new items are added to the status map
          for (final item in realItems) {
            _statusMap[item.id.toString()] = 'open';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching real listings: $e");
      setState(() => _isLoading = false);
    }
  }

  void _setStatus(int index, String status) {
    setState(() {
      _statusMap[_items[index].id] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == 'accepted' ? 'Accepted' : 'Declined'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        title: const Text(
          'Available Donations',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.6,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final item = _items[i];
                final status = _statusMap[item.id];
                final image = item.images.isNotEmpty ? item.images.first : "";

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// IMAGE
                          /// IMAGE (Smart Detection: Asset vs Network)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: image.startsWith('http')
                                ? Image.network(
                                    image,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image)),
                                  )
                                : Image.asset(
                                    image,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          const SizedBox(width: 14),

                          /// CONTENT
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.schedule,
                                  text: 'Pickup: ${item.pickupTime}',
                                ),
                                _InfoRow(
                                  icon: Icons.restaurant,
                                  text: item.quantity,
                                ),
                                _InfoRow(
                                  icon: Icons.calendar_today,
                                  text: item.expiry,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// ACTIONS
                      if (status != 'open')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: status == 'accepted'
                                ? Colors.green
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            status == 'accepted' ? 'Accepted' : 'Declined',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _setStatus(i, 'declined'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // 🔒 RESTRICTED ACCESS GATE
                                  if (!widget.isVerified) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text("Verification Pending"),
                                        content: const Text(
                                            "Your documents are still under verification. Please try after they have been verified."),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                    return; // Stop execution here
                                  }

                                  // ✅ PROCEED: Only for verified users
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReceiverDetailPage(
                                        item: item,
                                        onConfirmPickup: () {
                                          _setStatus(i, 'accepted');
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
