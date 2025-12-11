// lib/features/receiver/pages/providers_closeby.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ProvidersCloseByPage extends StatelessWidget {
  const ProvidersCloseByPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providers = List.generate(6, (i) => 'Provider ${i + 1}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Providers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: providers.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(providers[i]),
            subtitle: const Text('~500 m away'),
            trailing: const Icon(Icons.place),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
