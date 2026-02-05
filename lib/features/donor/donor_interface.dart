// lib/features/donor/donor_interface.dart
// FINAL — COMPLETE, ERROR-FREE, REQUESTED UI ONLY

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
    "subtitle": "Your small act of kindness feeds a hungry soul.",
  },
  {
    "title": "Be the Reason",
    "subtitle": "One donation can change someone’s day.",
  },
  {
    "title": "Share What You Can",
    "subtitle": "Excess food becomes hope.",
  },
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
    _loadLocation(); // ✅ ADD THIS LINE
    DonationRepo.instance.seedDemo();
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

  void _startHeroAutoFade() {
    _heroTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_heroController.hasClients) return;
      _heroIndex = (_heroIndex + 1) % featuredImages.length;
      _heroController.animateToPage(
        _heroIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onRepoChanged() {
    setState(() {});
  }

  Future<void> _loadDonorName() async {
    final prefs = await SharedPreferences.getInstance();
    _myName = prefs.getString('donor_name') ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoChanged);
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  // -------- SAFE DATE FORMATTER (prevents red screen) --------
  String _formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return '${value.day}/${value.month}';
    }
    return value.toString();
  }

  Widget _image(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : Container(color: Colors.grey.shade200);
  }

  void _onFabTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDonationsScreen()),
    ).then((_) => setState(() {}));
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

  bool _isNewDonation(Donation d) {
    if (!d.isNew) return false;
    return DateTime.now().difference(d.createdAt).inHours < 4;
  }

  @override
  Widget build(BuildContext context) {
    DonationRepo.instance.expireNewFlags();
    final donations = DonationRepo.instance.items;
    final donationCount = donations
        .where((d) =>
            d.isNew || d.donorName.toLowerCase() == _myName.toLowerCase())
        .length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBg,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT — Zepto style
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDCD6FF), // darker top (location emphasis)
                  Color(0xFFEDE9FF),
                  Color(0xFFF7F5FB), // blends into page background
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
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // HERO

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
                            // ORIGINAL IMAGE (NO OVERLAY)
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.22),
                                BlendMode.darken,
                              ),
                              child: _image(featuredImages[i]),
                            ),

                            // BOTTOM SHADOW ONLY (FIXES GREY SLAB)
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
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // TEXT
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    t['title']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2, // tight heading spacing
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 6), // document-like gap
                                  Text(
                                    t['subtitle']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFE6DEFF),
                                      height: 1.3, // readable body spacing
                                    ),
                                  ),
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

              // TOTAL DONATIONS
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
                            Text(
                              "$donationCount",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "TOTAL DONATIONS",
                              style: TextStyle(color: Colors.grey),
                            ),
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

              // PREVIOUS LIST HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      "Previous Lists",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DonorListing()),
                        );
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
                      return _donationCard(
                        donation: d,
                        isNew: _isNewDonation(d),
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
              offset: const Offset(0, 16),
            ),
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

  // ================= USER DONATION CARD =================

  Widget _donationCard({
    required dynamic donation,
    required bool isNew,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationDetail(donation: donation),
            ),
          );
        },
        child: Stack(
          children: [
            _donationSampleCard(
              image: donation.photoPaths.isNotEmpty
                  ? donation.photoPaths.first
                  : null,
              title: (donation.foodName?.trim().isNotEmpty ?? false)
                  ? donation.foodName!
                  : (donation.notes?.trim().isNotEmpty ?? false)
                      ? donation.notes!
                      : donation.category,
              qty: donation.quantity,
              category: donation.category,
              date: _formatDate(donation.createdAt),
              pickup: _formatDate(donation.pickupWindow),
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
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  // ================= SHARED CARD =================

  Widget _donationSampleCard({
    required String? image,
    required String title,
    required int qty,
    required String category,
    required String date,
    required String pickup,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: image != null
                ? SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: _image(image),
                  )
                : Container(
                    height: 140,
                    color: Colors.grey.shade200,
                  ),
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

// ================= SHARE FOOD DOTTED =================

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
              color: kLavenderSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: kLavender,
                  child: Icon(Icons.add, color: Colors.white),
                ),
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

// ================= DOTTED BORDER PAINTER =================

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
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
