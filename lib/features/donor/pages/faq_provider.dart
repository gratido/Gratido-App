// lib/features/donor/pages/faq_provider.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

/// Provider FAQ page — same visual style as the receiver FAQ (search bar, result count,
/// rounded cards, expand/collapse). Keeps all previously provided provider Q&A.
/// Use: Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQProviderPage()));
class FAQProviderPage extends StatefulWidget {
  const FAQProviderPage({Key? key}) : super(key: key);

  @override
  State<FAQProviderPage> createState() => _FAQProviderPageState();
}

class _FAQProviderPageState extends State<FAQProviderPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  static final List<Map<String, String>> _allFaqs = [
    {
      'q': 'How do I post a donation?',
      'a':
          'Open Post Donation, add photos, quantities and pickup window, then publish the listing.',
    },
    {
      'q': 'Can I edit or remove my post after publishing?',
      'a':
          'Yes — go to My Donations, open the listing and choose Edit or Delete.',
    },
    {
      'q': 'How do I mark a donation as picked up?',
      'a':
          'Once the item is collected, open the listing and tap Confirm pickup to complete it.',
    },
    {
      'q': 'Will receivers see my phone number automatically?',
      'a':
          'Contact details are visible after an acceptance or when you choose to share them.',
    },
    {
      'q': 'What is the pickup window and how does it work?',
      'a':
          'Pickup window is the time range you set when posting. Receivers must collect within that range.',
    },
    {
      'q': 'Can multiple receivers accept the same post?',
      'a':
          'Most posts are reserved for a single receiver. If you allow multiple pickups, mention it in the listing.',
    },
    {
      'q': 'Do I get notified when someone accepts?',
      'a':
          'Yes — in-app notifications are sent to inform you when someone accepts or messages you.',
    },
    {
      'q': 'How to handle no-shows?',
      'a':
          'Mark the request cancelled and relist the item. Consider adding notes to help receivers find the pickup location.',
    },
    {
      'q': 'How do I change quantity after posting?',
      'a':
          'Edit the listing from My Donations. If someone already accepted, notify them of changes.',
    },
    {
      'q': 'Can I restrict who can accept my donation?',
      'a':
          'Not currently. You can include a note in your listing requesting organisations only or verified receivers.',
    },
  ];

  List<Map<String, String>> _visibleFaqs = [];

  @override
  void initState() {
    super.initState();
    _visibleFaqs = List.from(_allFaqs);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _visibleFaqs = List.from(_allFaqs);
      } else {
        _visibleFaqs = _allFaqs.where((m) {
          final question = (m['q'] ?? '').toLowerCase();
          final answer = (m['a'] ?? '').toLowerCase();
          return question.contains(q) || answer.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF6A4CFF);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar (receiver-style)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Search FAQs',
                      textField: true,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search questions...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black45,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchFocus.unfocus();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // results count
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6,
              ),
              child: Row(
                children: [
                  Text(
                    '${_visibleFaqs.length} result${_visibleFaqs.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // FAQ list (receiver-like card style)
            Expanded(
              child: _visibleFaqs.isEmpty
                  ? const Center(child: Text('No FAQs match your search.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _visibleFaqs.length,
                      itemBuilder: (context, index) {
                        final item = _visibleFaqs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AnimatedFaqCard(
                            question: item['q'] ?? '',
                            answer: item['a'] ?? '',
                            accent: accent,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated card with expand/collapse behaviour and smooth size animation.
class _AnimatedFaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final Color accent;

  const _AnimatedFaqCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.accent,
  }) : super(key: key);

  @override
  State<_AnimatedFaqCard> createState() => _AnimatedFaqCardState();
}

class _AnimatedFaqCardState extends State<_AnimatedFaqCard> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row: question + rotating arrow
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: widget.question,
                        button: true,
                        hint: _expanded ? 'Tap to collapse' : 'Tap to expand',
                        child: Text(
                          widget.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _expanded ? 0.5 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 220),
                      builder: (context, val, child) {
                        return Transform.rotate(
                          angle: val * 3.1415926535,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.answer,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
