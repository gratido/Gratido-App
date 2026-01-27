import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratido_sample/features/donor/add_donations/add_donations.dart';

import 'donation_repo.dart';
import 'donation_detail.dart';

enum DonationFilter { all, d10, d30, month, year }

class MyDonations extends StatefulWidget {
  const MyDonations({super.key});

  @override
  State<MyDonations> createState() => _MyDonationsState();
}

class _MyDonationsState extends State<MyDonations> {
  String _myName = '';
  DonationFilter _activeFilter = DonationFilter.all;
  DonationFilter _tempFilter = DonationFilter.all;

  static const Color primary = Color(0xFF6E5CD6);

  final List<Color> qtyBgColors = const [
    Color(0xFFEDEBFF),
    Color(0xFFE8F5FF),
    Color(0xFFFFF2E6),
    Color(0xFFEFFAF1),
  ];
  final List<Color> qtyTextColors = const [
    Color(0xFF5C4BD6), // darker purple
    Color(0xFF1F6FB2), // darker blue
    Color(0xFFB45309), // darker orange
    Color.fromARGB(255, 15, 83, 40), // darker green
  ];

  @override
  void initState() {
    super.initState();
    _loadDonorName();
    DonationRepo.instance.addListener(_onRepoUpdated);
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoUpdated);
    super.dispose();
  }

  void _onRepoUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadDonorName() async {
    final prefs = await SharedPreferences.getInstance();
    _myName = prefs.getString('donor_name') ?? '';
    setState(() {});
  }

  // ---------------- IMAGE ----------------
  Widget _imageWidget(String? path) {
    if (path == null || path.trim().isEmpty) {
      return const ColoredBox(
        color: Color(0xFFF2F2F2),
        child: Icon(Icons.image_not_supported),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.image_not_supported);
  }

  // ---------------- CARD ----------------
  Widget _buildCard(Donation d, bool isLatest, int index) {
    final String title = (d.foodName?.trim().isNotEmpty ?? false)
        ? d.foodName!.trim()
        : d.category;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DonationDetail(donation: d)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E5CD6).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF9A8CFF).withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          children: [
            // IMAGE (fixed height)
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _imageWidget(
                        d.photoPaths.isNotEmpty ? d.photoPaths.first : null,
                      ),
                    ),
                    if (isLatest)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary,
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
            ),

            const SizedBox(height: 10),

            // TEXT + FOOTER (flexible area)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: qtyBgColors[index % qtyBgColors.length],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Qty ${d.quantity}',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color:
                                    qtyTextColors[index % qtyTextColors.length],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                d.expiryTime?.trim().isNotEmpty ?? false
                                    ? 'Exp: ${d.expiryTime}'
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: CustomPaint(
          painter: _DottedBorderPainter(color: primary),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 26,
            ),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 🔥 CRITICAL
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TITLE
                Text(
                  'NOTHING TILL NOW',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 6),

                // DIVIDER
                Container(
                  height: 1,
                  width: 52,
                  color: const Color(0xFF3E3E3E),
                ),

                const SizedBox(height: 10),

                // MAIN TEXT
                const Text(
                  'Ready to make a difference?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // SUB TEXT (2pt smaller)
                const Text(
                  'Share surplus food with those in need!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3E3E3E),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // CTA BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddDonationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Make your first post today',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    List<Donation> list = DonationRepo.instance.items
        .where((d) =>
            d.donorName.trim().toLowerCase() == _myName.trim().toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    list = list.where((d) {
      final days = now.difference(d.createdAt).inDays;

      switch (_activeFilter) {
        case DonationFilter.d10:
          return days <= 10;

        case DonationFilter.d30:
          return days <= 30;

        case DonationFilter.month:
          final firstDayOfThisMonth = DateTime(now.year, now.month, 1);
          final firstDayOfLastMonth = DateTime(
              firstDayOfThisMonth.year, firstDayOfThisMonth.month - 1, 1);
          return d.createdAt.isAfter(firstDayOfLastMonth) &&
              d.createdAt.isBefore(firstDayOfThisMonth);

        case DonationFilter.year:
          return days <= 365;

        default:
          return true;
      }
    }).toList();

    final latest = list.isEmpty ? null : list.first.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: list.isEmpty
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilterSheet,
                ),
              ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDE7FF),
              Color(0xFFF6F3FF),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: list.isEmpty
            ? _emptyState()
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 280, // fixed height → stable layout
                ),
                itemCount: list.length,
                itemBuilder: (_, i) =>
                    _buildCard(list[i], list[i].createdAt == latest, i),
              ),
      ),
      floatingActionButton: list.isEmpty
          ? null
          : FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddDonationsScreen(),
                  ),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  // ---------------- FILTER SHEET ----------------
  void _openFilterSheet() {
    _tempFilter = _activeFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          Widget filterTile(
            DonationFilter value,
            String label,
          ) {
            final bool selected = _tempFilter == value;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setSheetState(() => _tempFilter = value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? primary : Colors.grey.shade300,
                    width: selected ? 2 : 1,
                  ),
                  color:
                      selected ? primary.withOpacity(0.08) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? primary : Colors.black87,
                        ),
                      ),
                    ),

                    // RIGHT SIDE RADIO / CHECK
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? primary : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: selected ? primary : Colors.transparent,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DRAG HANDLE
                Container(
                  height: 5,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Filter by time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 12),

                // FILTER OPTIONS
                filterTile(DonationFilter.d10, '10 days ago'),
                const SizedBox(height: 10),
                filterTile(DonationFilter.d30, '30 days ago'),
                const SizedBox(height: 10),
                filterTile(DonationFilter.month, 'Last month'),
                const SizedBox(height: 10),
                filterTile(DonationFilter.year, 'Last year'),

                const SizedBox(height: 20),

                // CONFIRM BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _activeFilter = _tempFilter);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirm Selection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------- DOTTED BORDER ----------------
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashWidth = 6;
    const dashSpace = 4;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
