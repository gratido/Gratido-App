// lib/features/donor/map_picker.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selected;

  // Sample addresses — replace with real search results or maps API later
  final List<String> _samples = [
    'Central Park, City Mall Entrance',
    'Community Center, Main Hall',
    'Central Park, North Gate',
    'City Mall Entrance',
    'Near Old Library',
  ];

  List<String> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _samples;
    return _samples.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _select(String addr) {
    setState(() => _selected = addr);
  }

  void _confirm() {
    if (_selected != null) {
      Navigator.of(context).pop(_selected);
    } else if (_filtered.isNotEmpty) {
      Navigator.of(context).pop(_filtered.first);
    } else {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search address or landmark',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

            // List of addresses
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (c, i) {
                  final a = _filtered[i];
                  final selected = a == _selected;
                  return ListTile(
                    tileColor: selected ? Colors.blue.withOpacity(0.08) : null,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(a),
                    onTap: () => _select(a),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                  );
                },
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Select location',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
