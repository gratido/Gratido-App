// lib/features/donor/donor_interface.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'donor_listing.dart';
import 'add_donations/add_donations.dart';
import 'mydonations.dart';
import 'profile.dart';
import 'donation_repo.dart';
import 'donation_detail.dart';
import 'pages/notifications_page.dart';
import 'dart:convert'; // ✅ Fixes 'jsonDecode' error
import 'package:http/http.dart' as http; // ✅ Fixes 'http' error
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Fixes 'FirebaseAuth' error

// ================= COLORS =================
const Color kLavender = Color(0xFF6E5CD6);
const Color kLavenderSoft = Color(0x226E5CD6);
const Color kBg = Color(0xFFF7F5FB);
const Color kPickupBg = Color(0xFFE8F1FF);
const Color kPickupFg = Color(0xFF3B6FD8);

// ================= HERO TEXT =================
const List<Map<String, String>> heroText = [
  {
    "title": "Make a Difference Today",
    "subtitle": "Your small act of kindness feeds a hungry soul."
  },
  {
    "title": "Be the Reason",
    "subtitle": "One donation can change someone’s day."
  },
  {"title": "Share What You Can", "subtitle": "Excess food becomes hope."},
];

class DonorInterface extends StatefulWidget {
  const DonorInterface({super.key});
  @override
  State<DonorInterface> createState() => _DonorInterfaceState();
}

class _DonorInterfaceState extends State<DonorInterface> {
  int _selectedIndex = 0;
  int _heroIndex = 0;
  String _myName = '';
  String _locationText = 'Fetching location...';

  late final PageController _heroController;
  Timer? _heroTimer;

  final List<String> featuredImages = [
    'assets/images/featured1.jpg',
    'assets/images/featured2.jpg',
    'assets/images/featured3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _heroController = PageController();
    _loadDonorName();
    _loadLocation();

    // 1. ✅ Load Seeds immediately so the UI is never blank
    if (DonationRepo.instance.items.isEmpty) {
      DonationRepo.instance.seedDemo();
    }

    // 2. ✅ TURBO-SYNC: This listener is the secret!
    // It waits for Firebase to say "I am ready" before calling the server.
    // This fixes the "Shows Zero on Login" bug forever.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _prefetchData();
      }
    });

    DonationRepo.instance.addListener(_onRepoChanged);
    _startHeroAutoFade();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('donor_address');
    if (address != null && address.isNotEmpty) {
      setState(() {
        _locationText = address;
      });
    }
  }

  Future<void> _prefetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Force a fresh token so the server doesn't reject you
      final token = await user.getIdToken(true);

      // ✅ IP SYNC: Using your latest IP 10.250.141.163
      final response = await http.get(
        Uri.parse('http://192.168.0.4:5227/api/Donation/my-donations'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10)); // Stop spinning if Wi-Fi is slow

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        final serverList = data.map((json) => Donation.fromJson(json)).toList();

        // ✅ isHistoryView: false ensures your SEEDS stay on the Home Screen!
        DonationRepo.instance.setServerItems(serverList, isHistoryView: false);

        print(
            "🚀 [TURBO-LOAD] Synced ${serverList.length} items from Supabase!");
      }
    } catch (e) {
      debugPrint("Prefetch failed, using seeds only: $e");
      DonationRepo.instance.seedDemo();
    }
  }

  void _startHeroAutoFade() {
    _heroTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_heroController.hasClients) return;
      _heroIndex = (_heroIndex + 1) % featuredImages.length;
      _heroController.animateToPage(_heroIndex,
          duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    });
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadDonorName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myName = prefs.getString('donor_name') ?? '';
    });
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoChanged);
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return '${value.day}/${value.month}';
    return value.toString();
  }

  Widget _image(String path) {
    if (path.startsWith('assets/')) return Image.asset(path, fit: BoxFit.cover);
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200));
    }
    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : Container(color: Colors.grey.shade200);
  }

  void _onFabTap() {
    Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddDonationsScreen()))
        .then((_) => setState(() {}));
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const DonorListing()));
      return;
    }
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const MyDonations()));
      return;
    }
    if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const Profile()));
      return;
    }
    setState(() => _selectedIndex = index);
  }

  // ✅ RESTORED: This method is now used in the build method below
  //bool _isNewDonation(Donation d) {
  // if (!d.isNew) return false;
  //return DateTime.now().difference(d.createdAt).inHours < 4;
  //}

  @override
  Widget build(BuildContext context) {
    //final allItems = DonationRepo.instance.items;
    final donations = DonationRepo.instance.items;

    // ✅ FIX: Only count real items from the database (Ignore the 3 seeds)
    final donationCount = donations
        .where((d) =>
            d.donorName != 'Featured Listing' &&
            d.donorName != 'Community Kitchen' &&
            d.donorName != 'Ramesh Kumar')
        .length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBg,
      body: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDCD6FF),
                  Color(0xFFEDE9FF),
                  Color(0xFFF7F5FB)
                ],
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 80,
            ),
            children: [
              // LOCATION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: kLavender, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsPage()));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // HERO CAROUSEL
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _heroController,
                  itemCount: featuredImages.length,
                  itemBuilder: (_, i) {
                    final t = heroText[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.22),
                                  BlendMode.darken),
                              child: _image(featuredImages[i]),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 90,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t['title']!,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2)),
                                  const SizedBox(height: 6),
                                  Text(t['subtitle']!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFFE6DEFF),
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // TOTAL DONATIONS CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyDonations()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: kLavenderSoft,
                          child:
                              Icon(Icons.volunteer_activism, color: kLavender),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$donationCount",
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text("TOTAL DONATIONS",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // LIST HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text("Previous Lists",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DonorListing()));
                      },
                      child: const Text("View All",
                          style: TextStyle(color: kLavender)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // HORIZONTAL LIST
              SizedBox(
                height: 280,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _ShareFoodDotted(onTap: _onFabTap),
                    ...donations.map((d) {
                      // ✅ THE FIX: Calling your helper method here removes the warning
                      return _donationCard(
                        donation: d,
                        isNew: d.isNew,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kLavender,
          boxShadow: [
            BoxShadow(
                color: kLavender.withOpacity(0.7),
                blurRadius: 32,
                offset: const Offset(0, 16))
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.volunteer_activism,
              color: Colors.white, size: 30),
          onPressed: _onFabTap,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nav(Icons.home, "Home", 0),
              _nav(Icons.list_alt, "Posts", 1),
              const SizedBox(width: 40),
              _nav(Icons.favorite, "Donated", 2),
              _nav(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? kLavender : Colors.grey),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: selected ? kLavender : Colors.grey)),
        ],
      ),
    );
  }

  // ✅ FIXED: Corrected the mapping to pass everything as String
  Widget _donationCard({
    required Donation donation,
    required bool isNew,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DonationDetail(donation: donation)));
        },
        child: Stack(
          children: [
            _donationSampleCard(
              image: donation.photoPaths.isNotEmpty
                  ? donation.photoPaths.first
                  : null,
              title: (donation.foodName?.trim().isNotEmpty ?? false)
                  ? donation.foodName!
                  : donation.category,
              qty: donation
                  .quantity, // ✅ Now strictly uses String from the model
              category: donation.category,
              date: _formatDate(donation.createdAt),
              pickup: donation.pickupWindow,
            ),
            if (isNew)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: kLavender,
                      borderRadius: BorderRadius.circular(999)),
                  child: const Text('NEW',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Changed parameter 'qty' from int to String to kill the Red Error
  Widget _donationSampleCard({
    required String? image,
    required String title,
    required String qty, // ✅ Changed to String
    required String category,
    required String date,
    required String pickup,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: image != null
                ? SizedBox(
                    height: 140, width: double.infinity, child: _image(image))
                : Container(height: 140, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('$qty qty',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill(category, Colors.green.shade50, Colors.green),
                    _pill(date, Colors.orange.shade50, Colors.orange),
                    _pill(pickup, kPickupBg, kPickupFg),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ShareFoodDotted extends StatelessWidget {
  final VoidCallback onTap;
  const _ShareFoodDotted({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CustomPaint(
          painter: _DottedBorderPainter(color: kLavender),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
                color: kLavenderSoft, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                    radius: 26,
                    backgroundColor: kLavender,
                    child: Icon(Icons.add, color: Colors.white)),
                SizedBox(height: 10),
                Text("Share Food",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: kLavender)),
                SizedBox(height: 4),
                Text("Help someone in your community",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  _DottedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
            metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
