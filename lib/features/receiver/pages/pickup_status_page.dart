// lib/features/receiver/pages/pickup_status_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class PickupStatusPage extends StatelessWidget {
  const PickupStatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(child: Text('Pickup status list or map goes here')),
    );
  }
}
