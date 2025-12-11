// lib/features/donor/donor_interface.dart
// FINAL STABLE VERSION — FIXES:
// • NEW badge shows only for donor’s donations
// • Newly added donations appear FIRST in carousel (index 0)
// • PageView automatically jumps to left after update
// • No pixel overflow
// • index error FIXED in dots indicator

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'donation_detail.dart';
import 'donor_listing.dart';
import 'add_donations/add_donations.dart';
import 'mydonations.dart';
import 'profile.dart';
import 'donation_repo.dart';

class DonorInterface extends StatefulWidget {
  const DonorInterface({super.key});

  @override
  State<DonorInterface> createState() => _DonorInterfaceState();
}

class _DonorInterfaceState extends State<DonorInterface>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _myName = '';

  final List<String> featuredImages = [
    'assets/images/featured1.jpg',
    'assets/images/featured2.jpg',
    'assets/images/featured3.jpg',
  ];

  final List<Map<String, String>> _fallbackCarousel = [
    {
      'image': 'assets/images/sample1.jpg',
      'title': 'Donation Drive at Central Park',
      'desc': 'Fresh meals and packaged items available.',
    },
    {
      'image': 'assets/images/sample2.png',
      'title': 'Weekend Food Pack',
      'desc': 'Distribution of hygienic packs downtown.',
    },
    {
      'image': 'assets/images/sample3.jpg',
      'title': 'Community Kitchen',
      'desc': 'Hot meals served daily for families.',
    },
  ];

  late final PageController _carouselController;
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselController =
        PageController(initialPage: 0, viewportFraction: 0.86);

    _loadDonorName();
    _seedDemoIfEmpty();

    DonationRepo.instance.addListener(_onRepoUpdated);

    // auto slide
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_carouselController.hasClients) return;

      final items = _getSortedItems();
      if (items.isEmpty) return;

      final nextPage = (_carouselIndex + 1) % items.length;

      _carouselController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadDonorName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myName = prefs.getString('donor_name') ?? '';
    });
  }

  void _onRepoUpdated() {
    setState(() {});

    // jump to newest item (left-most)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // newest-first sorting
  List<Donation> _getSortedItems() {
    final items = DonationRepo.instance.items.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  void _seedDemoIfEmpty() {
    if (DonationRepo.instance.items.isEmpty) {
      DonationRepo.instance.seedDemo();
      for (final item in _fallbackCarousel) {
        DonationRepo.instance.addDonation(
          Donation(
            donorName: "Featured Listing",
            phone: "+91 9999999999",
            pickupLocation: "City Center",
            pickupWindow: "30 mins",
            category: "Cooked Meals",
            quantity: 20,
            photoPaths: [item["image"]!],
            hygieneConfirmed: true,
            preparedTime: "1–3 hours ago",
            expiryTime: "Today",
            notes: item["title"],
            isNew: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    DonationRepo.instance.removeListener(_onRepoUpdated);
    _carouselController.dispose();
    super.dispose();
  }

  bool _isNewDonation(Donation d) {
    // show NEW only for donor's own donations
    if (_myName.trim().isEmpty) return false;
    if (d.donorName.toLowerCase() != _myName.toLowerCase()) return false;

    return DateTime.now().difference(d.createdAt).inHours < 4;
  }

  Widget _imageAssetWithFallback(String? path, {BoxFit fit = BoxFit.cover}) {
    if (path == null) return Container(color: Colors.grey[200]);

    try {
      if (path.startsWith("assets/")) {
        return Image.asset(path, fit: fit);
      } else {
        final file = File(path);
        if (!file.existsSync()) return Container(color: Colors.grey[200]);
        return Image.file(file, fit: fit);
      }
    } catch (_) {
      return Container(color: Colors.grey[200]);
    }
  }

  void _onFabTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDonationsScreen()),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final items = _getSortedItems();
    final int count = items.isEmpty ? _fallbackCarousel.length : items.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Current Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                )
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // search bar
          Center(
            child: SizedBox(
              width: screenW * 0.88,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // hero banner
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: screenW * 0.90,
                height: 220,
                child: _imageAssetWithFallback(featuredImages[0]),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Previous Lists",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonorListing()),
                    );
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // CAROUSEL + DOTS
          SizedBox(
            height: 310,
            child: Column(
              children: [
                // CARDS
                Expanded(
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _carouselIndex = i),
                    itemBuilder: (context, index) {
                      final isFallback = items.isEmpty;

                      if (isFallback) {
                        final f = _fallbackCarousel[index];
                        return _carouselCard(
                          title: f["title"]!,
                          subtitle: f["desc"]!,
                          image: f["image"],
                          isNew: false,
                        );
                      }

                      final d = items[index];

                      return _carouselCard(
                        title: d.foodName?.isNotEmpty == true
                            ? d.foodName!
                            : d.category,
                        subtitle:
                            "Category: ${d.category} • Qty: ${d.quantity}",
                        image:
                            d.photoPaths.isNotEmpty ? d.photoPaths.first : null,
                        isNew: _isNewDonation(d),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationDetail(donation: d),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // FIXED DOTS INDICATOR — NO index error
                _buildDotsIndicator(count, _carouselIndex),

                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: _onFabTap,
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF5568FF), Color(0xFF6EC6FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _navItem(Icons.home, "Home", 0),
                  const SizedBox(width: 18),
                  _navItem(Icons.article_outlined, "Posts", 1),
                ],
              ),
              Row(
                children: [
                  _navItem(Icons.volunteer_activism, "Donated", 2),
                  const SizedBox(width: 18),
                  _navItem(Icons.person_outline, "Profile", 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CAROUSEL CARD ----------------

  Widget _carouselCard({
    required String title,
    required String subtitle,
    required String? image,
    required bool isNew,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: _imageAssetWithFallback(image),
                    ),
                  ),

                  // TEXT
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // NEW BADGE
            if (isNew)
              Positioned(
                top: -6,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- DOTS INDICATOR (fully fixed) ----------------

  Widget _buildDotsIndicator(int count, int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) {
          final bool active = (i == activeIndex);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 10 : 7,
            height: active ? 10 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.blueAccent : Colors.grey[300],
            ),
          );
        },
      ),
    );
  }

  // ---------------- NAV ITEM ----------------

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onNavTap(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.blueAccent : Colors.grey[600],
                size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.blueAccent : Colors.grey[600],
              ),
            )
          ],
        ),
      ),
    );
  }
}
