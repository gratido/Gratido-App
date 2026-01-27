// lib/features/receiver/pages/modern_faq_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ModernFaqPage extends StatefulWidget {
  const ModernFaqPage({Key? key}) : super(key: key);

  @override
  State<ModernFaqPage> createState() => _ModernFaqPageState();
}

class _ModernFaqPageState extends State<ModernFaqPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // 🔒 ALL 11 QUESTIONS — UNCHANGED
  static final List<Map<String, String>> _allFaqs = [
    {
      'q': 'How do I accept a food listing and what happens next?',
      'a':
          'Tap the "Accept" button on a listing card. The item will be reserved for you, provider is notified, and pickup details appear in the listing and your profile.',
    },
    {
      'q': 'Where can I see my accepted items and their status?',
      'a':
          'Open Profile → Accepted Listings to view items and their pickup status.',
    },
    {
      'q': 'What should I do if I cannot pick up an item after accepting it?',
      'a':
          'Open the accepted listing and cancel the request so the provider can offer it to others. Repeated no-shows may impact trust.',
    },
    {
      'q': 'How accurate are the prepared and expiry times shown on listings?',
      'a':
          'These times are provided by the provider. We recommend confirming with the provider if timing is critical.',
    },
    {
      'q': 'Can I contact the provider directly for pickup details?',
      'a':
          'Yes — after acceptance the provider’s phone number becomes visible so you can arrange pickup directly.',
    },
    {
      'q': 'Why did a listing disappear before I could accept it?',
      'a':
          'A listing may disappear because another receiver accepted it, the provider removed it, or it expired based on the pickup window.',
    },
    {
      'q': 'What happens if I accept but fail to pick up the item?',
      'a':
          'If you cannot pick it up, cancel the acceptance. This helps providers and other receivers. If you frequently miss pickups your access may be flagged.',
    },
    {
      'q': 'Can multiple receivers accept the same listing?',
      'a':
          'Most listings are reserved for a single receiver. If multiple pickups are allowed, the provider will state that in the listing.',
    },
    {
      'q': 'If the provider cancels a listing, will I be notified?',
      'a':
          'Yes — you will receive an in-app notification if a listing you were interested in or accepted is cancelled.',
    },
    {
      'q': 'How is priority decided for popular listings?',
      'a':
          'Priority is usually first-come-first-served (who accepts first). Community programs may apply extra rules like verification status.',
    },
    {
      'q': 'Is my account affected if I frequently decline listings?',
      'a':
          'Declining listings does not affect your account. However, repeatedly accepting and not picking up items may impact trust.',
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
    const primaryColor = Color(0xFF7F13EC);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(
                    '${_visibleFaqs.length} result${_visibleFaqs.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
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
                      accent: primaryColor,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // ✅ FIXED ARROW — NO JITTER
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.accent,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
