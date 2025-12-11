// lib/features/receiver/address_picker.dart
// ignore_for_file: deprecated_member_use, use_super_parameters, unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'address_pick_result.dart' show AddressPickResult;

class AddressPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final String initialLine1;
  final String initialLine2;
  final String initialBuilding;

  const AddressPickerPage({
    Key? key,
    required this.initialCenter,
    required this.initialLine1,
    required this.initialLine2,
    required this.initialBuilding,
  }) : super(key: key);

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  late LatLng _center;
  late String _line1;
  late String _line2;
  final TextEditingController _buildingCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
    _line1 = widget.initialLine1;
    _line2 = widget.initialLine2;
    _buildingCtrl.text = widget.initialBuilding;
  }

  void _onMapDragged(LatLng newCenter) {
    setState(() {
      _center = newCenter;
      // Later: reverse geocode to update _line1 & _line2
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color(0xFFEFF3F8),
                  child: Center(
                    child: Text(
                      'Map placeholder\nMove the map to position the pin',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ),
                const Icon(Icons.place, color: Colors.red, size: 36),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _guidanceBanner(),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Move pin to address location', bold: true),
                const SizedBox(height: 4),
                _line('Enter address details', color: Colors.black54),
                const SizedBox(height: 12),
                _line(_line1),
                _line(_line2, color: Colors.black54),
                const SizedBox(height: 12),
                TextField(
                  controller: _buildingCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Building, Floor, Locality',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        AddressPickResult(
                          position: _center,
                          addressLine1: _line1,
                          addressLine2: _line2,
                          buildingDetails: _buildingCtrl.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Save address'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _guidanceBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Move pin to address location',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String text, {Color color = Colors.black87, bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}
