import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'receiver_detail.dart';
import 'receiver_listings.dart';
import 'receiver_profile.dart';
import 'pages/receiver_notifications_page.dart';

// ✅ NEW IMPORTS (MODEL + DUMMY REPO)
import 'models/food_item.dart';
//import 'models/dummy_food_repo.dart';
import 'package:http/http.dart' as http; // ✅ Required for backend API call
import 'dart:convert'; // ✅ For JSON decoding

// ================= COLORS =================
const Color kPrimary = Color(0xFF6E5CD6);
const Color kPrimarySoft = Color(0x226E5CD6);
const Color kBg = Color(0xFFF6F3FF);

// ================= PAGE =================
class ReceiverHomePage extends StatefulWidget {
  final bool isVerified;
  final String address;
  final double lat; // ✅ NEW
  final double lng;
  const ReceiverHomePage({
    super.key,
    this.isVerified = false,
    this.address = "Loading location...",
    this.lat = 0.0,
    this.lng = 0.0,
  });

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> {
  int _navIndex = 0;

  late List<FoodItem> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbyDonations(); // ✅ Call the real API
  }

  // 🕵️‍♂️ SENIOR LOGIC: Fetches REAL data from C# Nearby API
  Future<void> _fetchNearbyDonations() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.4:5227/api/Donation/nearby?lat=${widget.lat}&lng=${widget.lng}&radius=100'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];

        setState(() {
          _cards = data.map((item) => FoodItem.fromJson(item)).toList();
          _isLoading = false;
        });
        debugPrint("✅ Fetched ${_cards.length} real donations nearby.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching donations: $e");
      setState(() => _isLoading = false);
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: false, // ✅ Keeps FAB static
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: kPrimary)) // ✅ Show loader
          : RefreshIndicator(
              // ✅ Allow user to pull-to-refresh
              onRefresh: _fetchNearbyDonations,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _header(),
                      const SizedBox(height: 11),
                      _search(),
                      const SizedBox(height: 15),
                      _hero(),
                      const SizedBox(height: 20),
                      // Show a message if no food is found
                      if (_cards.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                              "No donations nearby right now. Try again later!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                        )
                      else
                        _stackArea(),
                      const SizedBox(height: 8),
                      if (_cards.isNotEmpty) _swipeHint(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _fab(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: kPrimary),
          const SizedBox(width: 6),
          Expanded(
            // ✅ Added Expanded to prevent overflow
            child: Text(
              widget.address, // ✅ Uses dynamic address from registration
              maxLines: 1, // ✅ Restrict to one line
              overflow: TextOverflow.ellipsis, // ✅ Adds "..." if too long
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReceiverNotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for food near you...",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= HERO =================
  Widget _hero() {
    return SizedBox(
      height: 200,
      child: PageView(
        children: const [
          _HeroCard(
            image: "assets/images/h1.svg",
            title: "From Excess to Impact",
            subtitle:
                "Every meal shared is a step towards a zero-waste community.",
          ),
          _HeroCard(
            image: "assets/images/h2.jpeg",
            title: "Share Food. Share Hope.",
            subtitle: "Connecting surplus meals with those who need them.",
          ),
        ],
      ),
    );
  }

  // ================= STACK =================
  Widget _stackArea() {
    const cardHeight = 360.0;
    const verticalOffset = 24.0;
    const maxVisible = 3;
    const bottomPadding = 16.0;

    final visibleCards = _cards.take(maxVisible).toList();

    return SizedBox(
      height: cardHeight +
          (visibleCards.length - 1) * verticalOffset +
          bottomPadding,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: List.generate(visibleCards.length, (i) {
          final depth = visibleCards.length - 1 - i;
          final card = visibleCards[i];

          final scale = 1.0 - depth * 0.035;

          return Positioned(
            top: depth * verticalOffset,
            left: 20,
            right: 20,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(
                        depth == 0 ? 0.25 : 0.10,
                      ),
                      blurRadius: depth == 0 ? 40 : 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  borderRadius: BorderRadius.circular(32),
                  child: _SwipeCard(
                    card: card,
                    onAccept: () => _accept(card),
                    onDecline: () => _decline(card),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ================= ACTIONS =================
  void _accept(FoodItem item) {
    // ✅ RESTRICTED ACCESS POPUP
    if (!widget.isVerified) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Verification Pending"),
          content: const Text(
              "Your documents are still under verification. Please try after they have been verified."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return; // Stop here
    }

    // Existing logic for verified users
    setState(() => _cards.remove(item));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiverDetailPage(item: item),
      ),
    );
  }

  // ✅ ADD THIS BACK: It was missing in your error log
  void _decline(FoodItem item) {
    setState(() => _cards.remove(item));
  }

  // ================= FOOTER =================
  Widget _swipeHint() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.keyboard_double_arrow_up, color: Colors.grey, size: 16),
        Text(
          "SWIPE LEFT TO DECLINE • RIGHT TO ACCEPT",
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  // ================= FAB =================
  Widget _fab() {
    return Container(
      width: 64,
      height: 64,
      // The FAB is docked to the center. To keep it static during popups,
      // ensure the Scaffold's resizeToAvoidBottomInset is false.
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kPrimary,
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.list_alt, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReceiverListingsPage(),
            ),
          );
        },
      ),
    );
  }

  // ================= NAV =================
  Widget _bottomNav() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.home, "Home", 0),
            const SizedBox(width: 40),
            _nav(Icons.person, "Profile", 1),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int index) {
    final selected = _navIndex == index;
    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReceiverProfilePage(),
            ),
          );
        }
        setState(() => _navIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? kPrimary : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? kPrimary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= HERO CARD =================
class _HeroCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _HeroCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ---------- IMAGE ----------
            image.endsWith('.svg')
                ? SvgPicture.asset(
                    image,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),

            // ---------- CONTRAST REDUCER (softens image) ----------
            Container(
              color: Colors.black.withOpacity(0.08),
            ),

            // ---------- PURPLE GRADIENT SHADOW ----------
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(230, 0, 0, 0), // deep purple
                      Color.fromARGB(153, 0, 0, 0),
                      Color(0x332E1F5E),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ---------- TEXT ----------
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFE6DEFF),
                      height: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SWIPE CARD =================
class _SwipeCard extends StatefulWidget {
  final FoodItem card;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _SwipeCard({
    required this.card,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        setState(() => _dx += d.delta.dx);
      },
      onHorizontalDragEnd: (_) {
        if (_dx > 120) {
          widget.onAccept();
        } else if (_dx < -120) {
          widget.onDecline();
        }
        setState(() => _dx = 0);
      },
      child: Transform.translate(
        offset: Offset(_dx, 0),
        child: _foodCard(widget.card),
      ),
    );
  }

  Widget _foodCard(FoodItem card) {
    final String imagePath = card.images.isNotEmpty ? card.images.first : "";
    final bool isWebUrl = imagePath.startsWith(
        '/data/user/0/com.example.gratido_sample/cache/scaled_318b768e-004d-41d2-8a0a-0a7387072b454890145301184743664.jpg,/data/user/0/com.example.gratido_sample/cache/scaled_0fd07c22-e402-4e88-a6c5-8c2d5261ff724575523712942807748.jpg');

    return Material(
      borderRadius: BorderRadius.circular(32),
      elevation: 10,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                card.images.first,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _infoColumn(
                      icon: Icons.schedule,
                      label: "Pickup",
                      value: card.pickupTime,
                    ),
                    _divider(),
                    _infoColumn(
                      icon: Icons.restaurant,
                      label: "Quantity",
                      value: card.quantity,
                    ),
                    _divider(),
                    _infoColumn(
                      icon: Icons.calendar_today,
                      label: "Expiry",
                      value: card.expiry,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                _pill("DECLINE", kPrimarySoft, widget.onDecline),
                const SizedBox(width: 12),
                _pill("ACCEPT", kPrimary, widget.onAccept),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: kPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // ✅ GUARANTEED safety
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300.withOpacity(0.6),
    );
  }

  Widget _pill(String text, Color bg, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: bg == kPrimary
                ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: bg == kPrimary ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
