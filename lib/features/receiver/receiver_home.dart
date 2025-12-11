// lib/features/receiver/receiver_home_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Replace these imports with your real pages
import 'receiver_listings.dart';
import 'receiver_profile.dart';
import 'receiver_detail.dart';

class ReceiverHomePage extends StatefulWidget {
  const ReceiverHomePage({super.key});

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage>
    with TickerProviderStateMixin {
  final PageController _carouselController = PageController();
  Timer? _carouselTimer;
  int _carouselIndex = 0;
  int _selectedNav = 0;

  final List<String> rotatingImages = [
    'https://picsum.photos/1200/600?random=1',
    'https://picsum.photos/1200/600?random=2',
    'https://picsum.photos/1200/600?random=3',
    'https://picsum.photos/1200/600?random=4',
  ];

  final List<Map<String, dynamic>> _sampleItems = [
    {
      'id': 'i0',
      'title': 'Bakery - Croissants',
      'time': '10:00 - 12:00',
      'images': ['https://picsum.photos/seed/1/800/450'],
      'status': 'open',
    },
    {
      'id': 'i1',
      'title': 'Prepared - Veg Curry',
      'time': '15:00 - 17:00',
      'images': ['https://picsum.photos/seed/2/800/450'],
      'status': 'open',
    },
    {
      'id': 'i2',
      'title': 'Cooked Meals - Mixed',
      'time': '12:00 - 14:00',
      'images': ['https://picsum.photos/seed/3/800/450'],
      'status': 'open',
    },
    {
      'id': 'i3',
      'title': 'Salads - Fresh Garden',
      'time': '09:30 - 11:30',
      'images': ['https://picsum.photos/seed/4/800/450'],
      'status': 'open',
    },
  ];

  int _topIndex = 0;
  final Map<String, AnimationController> _fadeControllers = {};

  @override
  void initState() {
    super.initState();

    // Auto carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      _carouselIndex = (_carouselIndex + 1) % rotatingImages.length;
      _carouselController.animateToPage(
        _carouselIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });

    // Precache images (optional with CachedNetworkImage)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final url in rotatingImages) {
        precacheImage(NetworkImage(url), context);
      }
      for (final item in _sampleItems) {
        if (item['images'] != null) {
          for (final im in (item['images'] as List)) {
            precacheImage(NetworkImage(im.toString()), context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    for (final c in _fadeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleList {
    if (_topIndex >= _sampleItems.length) return [];
    return _sampleItems.sublist(_topIndex);
  }

  Future<void> _declineTopItemWithFade() async {
    if (_topIndex >= _sampleItems.length) return;
    final idx = _topIndex;
    final id = _sampleItems[idx]['id'] as String;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeControllers[id] = controller;

    await controller.forward();

    setState(() {
      _sampleItems[idx]['status'] = 'declined';
      _topIndex += 1;
    });

    controller.dispose();
    _fadeControllers.remove(id);
  }

  void _acceptTopItem({
    bool navigateToDetail = false,
    Map<String, dynamic>? item,
  }) {
    if (_topIndex >= _sampleItems.length) return;
    final acceptedItem =
        item ?? Map<String, dynamic>.from(_sampleItems[_topIndex]);
    _sampleItems[_topIndex]['status'] = 'accepted';

    setState(() {
      _topIndex += 1;
    });

    if (navigateToDetail) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiverDetailPage(item: acceptedItem),
        ),
      );
    }
  }

  void _onCarouselTap(int index) {
    final url = rotatingImages[index];
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleList;
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Header: only location
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Current location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Extra spacing to move down search bar & carousel
                const SizedBox(height: 20),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () async {
                      await showSearch(
                        context: context,
                        delegate: _SimpleSearchDelegate(),
                      );
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black12),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Search...',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.search, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _carouselController,
                        itemCount: rotatingImages.length,
                        onPageChanged: (i) =>
                            setState(() => _carouselIndex = i),
                        itemBuilder: (c, index) {
                          final url = rotatingImages[index];
                          return GestureDetector(
                            onTap: () => _onCarouselTap(index),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Card stack
                Expanded(
                  child: visible.isEmpty
                      ? const Center(
                          child: Text(
                            'No more listings',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final stackOffset = constraints.maxHeight * 0.06;
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                for (int i = visible.length - 1; i >= 0; i--)
                                  if (i <= 2)
                                    _buildStackCard(
                                      item: visible[i],
                                      depth: i,
                                      globalIndex: _topIndex + i,
                                      isTop: i == 0,
                                      extraTopOffset: stackOffset,
                                    ),
                              ],
                            );
                          },
                        ),
                ),

                SizedBox(height: mq.padding.bottom + 36),
              ],
            ),
          ),

          // Floating nav bar
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: SoftGlassNavBar(
              selectedIndex: _selectedNav,
              onTap: (i) {
                if (i == 0) {
                  setState(() => _selectedNav = 0);
                } else if (i == 10) {
                  setState(() => _selectedNav = 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReceiverListingsPage()),
                  );
                } else if (i == 1) {
                  setState(() => _selectedNav = 2);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReceiverProfilePage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ _buildStackCard ------------------
  Widget _buildStackCard({
    required Map<String, dynamic> item,
    required int depth,
    required int globalIndex,
    required bool isTop,
    double extraTopOffset = 0,
  }) {
    final double top = 8 + extraTopOffset + depth * 14;
    final double inset = depth * 14;
    final double scale = 1 - depth * 0.018;
    const double cardHeight = 360;

    final id = item['id'] as String?;
    final fadeController = id != null ? _fadeControllers[id] : null;

    Widget content = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: (12 - depth * 3).clamp(2, 12).toDouble(),
      child: SizedBox(
        height: cardHeight,
        child: Column(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: (item['images'] as List).isNotEmpty
                      ? item['images'][0]
                      : '',
                  placeholder: (_, __) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pickup Time: ${item['time'] ?? ''}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final _ = item['id'] as String;
                              await _declineTopItemWithFade();
                              // No snackbar on decline by button (or optionally keep)
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('DECLINE'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _acceptTopItem(
                                navigateToDetail: true,
                                item: item,
                              );
                              // No snackbar on accept by button (or optionally keep)
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ACCEPT'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isTop) {
      return Positioned(
        top: top + 6,
        left: 20 + inset,
        right: 20 + inset,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Opacity(opacity: 1 - depth * 0.08, child: content),
        ),
      );
    }

    // Top card: Dismissible with custom swipe backgrounds & blur
    return Positioned(
      top: top,
      left: 20,
      right: 20,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Dismissible(
          key: ValueKey(item['id']),
          direction: DismissDirection.horizontal,
          background: _buildSwipeBackground(
            color: Colors.purple.withOpacity(0.8),
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _buildSwipeBackground(
            color: Colors.orange.withOpacity(0.8),
            alignment: Alignment.centerRight,
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right = accept
              _acceptTopItem(navigateToDetail: true, item: item);
              return true;
            } else {
              // Swipe left = decline
              await _declineTopItemWithFade();
              return true;
            }
          },
          onDismissed: (_) {
            if (_topIndex < 0) _topIndex = 0;
          },
          child: fadeController != null
              ? AnimatedBuilder(
                  animation: fadeController,
                  builder: (_, child) {
                    final t = fadeController.value;
                    return Opacity(opacity: 1 - t, child: child);
                  },
                  child: content,
                )
              : content,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: color,
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

// ----------------- SoftGlassNavBar -----------------
class SoftGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const SoftGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconButton(context, Icons.home_rounded, 0),
              _centerFab(context),
              _iconButton(context, Icons.person_rounded, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, int index) {
    final active = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? Colors.deepPurple : Colors.black54,
            ),
            const SizedBox(height: 4),
            if (active)
              Container(
                width: 26,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _centerFab(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(10),
      child: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.28),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}

// ----------------- Simple Search Delegate -----------------
class _SimpleSearchDelegate extends SearchDelegate<String> {
  final List<String> _fakeSuggestions = [
    'Bakery',
    'Salads',
    'Cooked Meals',
    'Prepared',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, ''),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Search results for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? _fakeSuggestions
        : _fakeSuggestions
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () {
          query = suggestions[i];
          showResults(context);
        },
      ),
    );
  }
}
