// lib/features/receiver/address_picker.dart
// ignore_for_file: deprecated_member_use, use_super_parameters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'address_pick_result.dart';

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
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _buildingCtrl = TextEditingController();

  LatLng? _currentLatLng;
  String _addressLine1 = 'Fetching location...';
  String _addressLine2 = '';

  bool _isLoading = false;
  String _lastSearch = '';
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _buildingCtrl.text = widget.initialBuilding;

    _currentLatLng = widget.initialCenter;

    if (widget.initialLine1.isNotEmpty) {
      _addressLine1 = widget.initialLine1;
      _addressLine2 = widget.initialLine2;
    } else {
      _getCurrentLocation();
    }
  }

  // ================= CURRENT LOCATION =================

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final location = Location();

      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      final data = await location.getLocation();
      final latLng = LatLng(data.latitude!, data.longitude!);

      setState(() => _currentLatLng = latLng);
      _mapController.move(latLng, 16);

      await _reverseGeocode(latLng);
    } finally {
      _isLoading = false;
    }
  }

  // ================= MAP MOVE =================

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      if (_isLoading) return;

      final center = event.camera.center;
      _currentLatLng = center;
      _reverseGeocode(center);
    }
  }

  // ================= SEARCH =================

  Future<void> _searchAddress(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (trimmed == _lastSearch) return;

    final now = DateTime.now();
    if (now.difference(_lastRequestTime).inMilliseconds < 800) return;
    if (_isLoading) return;

    _isLoading = true;
    _lastSearch = trimmed;
    _lastRequestTime = now;

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search"
        "?q=${Uri.encodeComponent(trimmed)}"
        "&format=json"
        "&addressdetails=1"
        "&limit=1"
        "&countrycodes=in",
      );

      final res = await http.get(
        url,
        headers: {'User-Agent': 'gratido-app'},
      );

      if (res.statusCode != 200) return;

      final list = json.decode(res.body) as List;
      if (list.isEmpty) return;

      final latLng = LatLng(
        double.parse(list.first['lat']),
        double.parse(list.first['lon']),
      );

      setState(() => _currentLatLng = latLng);
      _mapController.move(latLng, 16);

      await _reverseGeocode(latLng);
    } finally {
      _isLoading = false;
    }
  }

  // ================= REVERSE GEOCODE =================

  Future<void> _reverseGeocode(LatLng latLng) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?format=json"
        "&zoom=18"
        "&lat=${latLng.latitude}"
        "&lon=${latLng.longitude}",
      );

      final res = await http.get(
        url,
        headers: {'User-Agent': 'gratido-app'},
      );

      if (res.statusCode != 200) return;

      final data = json.decode(res.body);
      final addr = data['address'];

      final line1 = [
        addr['road'],
        addr['suburb'] ?? addr['neighbourhood'],
      ].where((e) => e != null).join(', ');

      final line2 = [
        addr['city'] ?? addr['town'],
        addr['state'],
      ].where((e) => e != null).join(', ');

      setState(() {
        _addressLine1 = line1;
        _addressLine2 = line2;
      });
    } finally {
      _isLoading = false;
    }
  }

  // ================= CONFIRM =================

  void _confirmAndReturn() {
    if (_currentLatLng == null) return;

    Navigator.pop(
      context,
      AddressPickResult(
        position: _currentLatLng!,
        addressLine1: _addressLine1,
        addressLine2: _addressLine2,
        buildingDetails: _buildingCtrl.text.trim(),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌍 MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng ?? const LatLng(20, 78),
              initialZoom: 5,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=gA9zLzMGmU4X1tFmnSBE',
                userAgentPackageName: 'com.gratido.app',
              ),
            ],
          ),

          /// 📍 AVATAR MARKER
          Center(
            child: IgnorePointer(child: _avatarMarker()),
          ),

          /// 🔍 SEARCH BAR
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                controller: _searchCtrl,
                enabled: !_isLoading,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchAddress,
                decoration: InputDecoration(
                  hintText: "Search for an address...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          /// 📍 MY LOCATION BUTTON
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.4,
            child: _mapButton(Icons.my_location, _getCurrentLocation),
          ),

          /// ⬆️ BOTTOM SHEET
          _bottomSheet(),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _avatarMarker() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(blurRadius: 15, color: Colors.black26),
        ],
        color: const Color(0xFF6A4CFF),
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 28),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10),
          ],
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }

  Widget _bottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          height: 260,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Selected location",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(_addressLine1,
                  style: const TextStyle(color: Colors.black87)),
              Text(_addressLine2, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4CFF),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _confirmAndReturn,
                child: const Text(
                  "Confirm Location →",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
