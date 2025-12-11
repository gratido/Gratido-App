// lib/features/receiver/pages/history_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(8, (i) => 'Pickup ${i + 1} — Completed');
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index]),
          subtitle: const Text('Completed — 2 hours ago'),
          onTap: () {},
        ),
      ),
    );
  }
}
