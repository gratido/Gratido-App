import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'receiver_detail.dart';
import 'receiver_listings.dart';
import 'receiver_profile.dart';
//import 'pages/receiver_notifications_page.dart';
import 'models/food_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color kPrimary = Color(0xFF6E5CD6);
const Color kPrimarySoft = Color(0x226E5CD6);
const Color kBg = Color(0xFFF6F3FF);

class ReceiverHomePage extends StatefulWidget {
  final bool isVerified;
  final String address;
  final double lat;
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
  late List<FoodItem> _allCards = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNearbyDonations();
  }

  Future<void> _fetchNearbyDonations() async {
    const String laptopIp = "192.168.0.5";
    const double searchRadius = 15.0;

    try {
      debugPrint(
        "Searching within ${searchRadius}km of Lat: ${widget.lat}, Lng: ${widget.lng}",
      );
      debugPrint("HOME LAT: ${widget.lat}, LNG: ${widget.lng}");

      final response = await http.get(
        Uri.parse(
          'http://$laptopIp:5227/api/Donation/nearby?lat=${widget.lat}&lng=${widget.lng}&radius=$searchRadius',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];

        setState(() {
          _allCards = data.map((item) => FoodItem.fromJson(item)).toList();
          _cards = List.from(_allCards); // Copy for filtering
          _isLoading = false;
        });

        debugPrint("Found ${_cards.length} donations.");
      } else {
        debugPrint("Server error: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterFood(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      setState(() {
        _cards = List.from(_allCards);
      });
    } else {
      setState(() {
        _cards = _allCards.where((item) {
          final titleMatch = item.title.toLowerCase().contains(search);
          final categoryMatch = item.category.toLowerCase().contains(search);
          return titleMatch || categoryMatch;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary),
            )
          : RefreshIndicator(
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
                      if (_cards.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "No donations nearby right now. Try again later!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: kPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                  builder: (_) => ReceiverListingsPage(
                    isVerified: widget.isVerified,
                    lat: widget.lat, // ✅ Pass current lat
                    lng: widget.lng, // ✅ Pass current lng
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: _filterFood,
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

  void _accept(FoodItem item) {
    if (!widget.isVerified) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Verification Pending"),
          content: const Text(
            "Your documents are still under verification. Please try after they have been verified.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _cards.remove(item));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiverDetailPage(item: item),
      ),
    );
  }

  void _decline(FoodItem item) {
    setState(() => _cards.remove(item));
  }

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

  Widget _fab() {
    return Container(
      width: 64,
      height: 64,
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
              builder: (_) => ReceiverListingsPage(
                isVerified: widget.isVerified,
                lat: widget.lat,
                lng: widget.lng,
              ),
            ),
          );
        },
      ),
    );
  }

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
            image.endsWith('.svg')
                ? SvgPicture.asset(
                    image,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
            Container(
              color: Colors.black.withOpacity(0.08),
            ),
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
                      Color.fromARGB(230, 0, 0, 0),
                      Color.fromARGB(153, 0, 0, 0),
                      Color(0x332E1F5E),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
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

    final bool isWebUrl =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

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
              child: imagePath.isEmpty
                  ? Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : isWebUrl
                      ? Image.network(
                          imagePath,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          imagePath,
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
                _pill(
                  "DECLINE",
                  kPrimarySoft,
                  widget.onDecline,
                ),
                const SizedBox(width: 12),
                _pill(
                  "ACCEPT",
                  kPrimary,
                  widget.onAccept,
                ),
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
            overflow: TextOverflow.ellipsis,
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
