// lib/features/donor/mydonations.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';
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
  DonationFilter _activeFilter = DonationFilter.all;
  DonationFilter _tempFilter = DonationFilter.all;
  bool _isLoading = true;

  static const Color primary = Color(0xFF6E5CD6);

  final List<Color> qtyBgColors = const [
    Color(0xFFEDEBFF),
    Color(0xFFE8F5FF),
    Color(0xFFFFF2E6),
    Color(0xFFEFFAF1)
  ];
  final List<Color> qtyTextColors = const [
    Color(0xFF5C4BD6),
    Color(0xFF1F6FB2),
    Color(0xFFB45309),
    Color.fromARGB(255, 15, 83, 40)
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    DonationRepo.instance.addListener(_onRepoUpdated);
  }

  @override
  void dispose() {
    DonationRepo.instance.removeListener(_onRepoUpdated);
    super.dispose();
  }

  // ✅ UPDATED: Fixed IP and Speed Optimization
  Future<void> _fetchHistory() async {
    if (DonationRepo.instance.items.where((d) => d.id.length < 10).isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('http://192.168.0.4:5227/api/Donation/my-donations'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("📡 RAW SERVER DATA: ${response.body}");
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        final serverList = data.map((json) => Donation.fromJson(json)).toList();

        // Passing isHistoryView: true keeps the Seeds hidden here
        DonationRepo.instance.setServerItems(serverList, isHistoryView: true);
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onRepoUpdated() {
    if (mounted) setState(() {});
  }

  Widget _imageWidget(String? path) {
    if (path == null || path.trim().isEmpty) {
      return const ColoredBox(
          color: Color(0xFFF2F2F2), child: Icon(Icons.image_not_supported));
    }
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
    }
    if (path.startsWith('assets/')) return Image.asset(path, fit: BoxFit.cover);
    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.image_not_supported);
  }

  Widget _buildCard(Donation d, bool isLatest, int index) {
    final String title = (d.foodName?.trim().isNotEmpty ?? false)
        ? d.foodName!.trim()
        : d.category;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DonationDetail(donation: d))),
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10)),
                BoxShadow(
                    color: const Color(0xFF9A8CFF).withOpacity(0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 18)),
              ]),
          child: Column(children: [
            AspectRatio(
                aspectRatio: 4 / 5,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(children: [
                      Positioned.fill(
                          child: _imageWidget(d.photoPaths.isNotEmpty
                              ? d.photoPaths.first
                              : null)),
                      if (isLatest || d.isNew)
                        Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(999)),
                                child: const Text('NEW',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)))),
                      Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: d.status == "Available"
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(d.status.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 7,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))),
                    ]))),
            const SizedBox(height: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(d.category,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const Spacer(),
                  Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.grey.shade200))),
                      child: Row(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: qtyBgColors[index % qtyBgColors.length],
                                borderRadius: BorderRadius.circular(5)),
                            child: Text('Qty ${d.quantity}',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: qtyTextColors[
                                        index % qtyTextColors.length]))),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    // ✅ THE FIX: Displays the actual date string from the Repo
                                    d.expiryTime?.trim().isNotEmpty == true
                                        ? 'Exp: ${d.expiryTime}'
                                        : 'Exp: N/A',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey.shade500)))),
                      ])),
                ])),
          ])),
    );
  }

  // ✅ RESTORED: Exact UI logic from your original code (Dotted box + divider + subtext)
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: CustomPaint(
          painter: _DottedBorderPainter(color: primary),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('NOTHING TILL NOW',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Container(height: 1, width: 52, color: const Color(0xFF3E3E3E)),
                const SizedBox(height: 10),
                const Text('Ready to make a difference?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                const Text('Share surplus food with those in need!',
                    style: TextStyle(fontSize: 14, color: Color(0xFF3E3E3E)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddDonationsScreen()))
                          .then((_) => _fetchHistory());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Make your first post today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<Donation> lists = DonationRepo.instance.items
        .where((d) => !d.id
                .contains('seed') // Only show items that don't have a 'seed' ID
            )
        .toList();
    List<Donation> list = lists.toList();

    // Filtering Logic
    list = list.where((d) {
      final days = now.difference(d.createdAt).inDays;
      switch (_activeFilter) {
        case DonationFilter.d10:
          return days <= 10;
        case DonationFilter.d30:
          return days <= 30;
        case DonationFilter.month:
          return d.createdAt.month == now.month && d.createdAt.year == now.year;
        case DonationFilter.year:
          return days <= 365;
        default:
          return true;
      }
    }).toList();

    final latest = list.isEmpty ? null : list.first.createdAt;

    return Scaffold(
      appBar: AppBar(
          title: Text('My History (${list.length})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh), onPressed: _fetchHistory),
            if (list.isNotEmpty)
              IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilterSheet),
          ]),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFEDE7FF), Color(0xFFF6F3FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : list.isEmpty
                ? _emptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 280),
                    itemCount: list.length,
                    itemBuilder: (_, i) =>
                        _buildCard(list[i], list[i].createdAt == latest, i)),
      ),
      floatingActionButton: (_isLoading || list.isEmpty)
          ? null // Hide when loading or when list is empty
          : FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddDonationsScreen()))
                  .then((_) => _fetchHistory()),
            ),
    );
  }

  void _openFilterSheet() {
    _tempFilter = _activeFilter;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => StatefulBuilder(builder: (context, setSheetState) {
              Widget tile(DonationFilter v, String l) {
                final sel = _tempFilter == v;
                return InkWell(
                    onTap: () => setSheetState(() => _tempFilter = v),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: sel ? primary : Colors.grey.shade300,
                                width: sel ? 2 : 1),
                            color: sel
                                ? primary.withOpacity(0.08)
                                : Colors.transparent),
                        child: Row(children: [
                          Text(l,
                              style: TextStyle(
                                  color: sel ? primary : Colors.black87,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          const Spacer(),
                          if (sel)
                            const Icon(Icons.check_circle, color: primary),
                        ])));
              }

              return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    tile(DonationFilter.all, 'All History'),
                    tile(DonationFilter.d10, 'Last 10 Days'),
                    tile(DonationFilter.month, 'This Month'),
                    tile(DonationFilter.year, 'This Year'),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            onPressed: () {
                              setState(() => _activeFilter = _tempFilter);
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm Selection',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))))
                  ]));
            }));
  }
}

// ✅ DEFINED OUTSIDE STATE CLASS TO FIX Syntax Errors
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
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dashWidth), paint);
        d += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
