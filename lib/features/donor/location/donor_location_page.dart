import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:gratido_sample/features/donor/donor_interface.dart';

class DonorLocationPage extends StatefulWidget {
  const DonorLocationPage({super.key});

  @override
  State<DonorLocationPage> createState() => _DonorLocationPageState();
}

class _DonorLocationPageState extends State<DonorLocationPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng? _currentLocation;
  String _addressText = "Fetching location...";

  // 🔒 stability guards
  bool _isLoading = false;
  String _lastSearch = '';
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ================= CURRENT LOCATION =================

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final location = Location();

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

      setState(() => _currentLocation = latLng);
      _mapController.move(latLng, 16);

      await _fetchAddressFromLatLng(latLng);
    } finally {
      _isLoading = false;
    }
  }

  // ================= DRAG TO SELECT =================

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      if (_isLoading) return;

      final center = event.camera.center;
      _currentLocation = center;
      _fetchAddressFromLatLng(center);
    }
  }

  // ================= SEARCH =================

  Future<void> _searchAddress(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // prevent duplicate & spam
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
        "&limit=1"
        "&countrycodes=in",
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'gratido-app'},
      );

      if (response.statusCode != 200) return;

      final list = json.decode(response.body) as List;
      if (list.isEmpty) return;

      final latLng = LatLng(
        double.parse(list.first['lat']),
        double.parse(list.first['lon']),
      );

      setState(() => _currentLocation = latLng);
      _mapController.move(latLng, 16);

      await _fetchAddressFromLatLng(latLng);
    } finally {
      _isLoading = false;
    }
  }

  // ================= REVERSE GEOCODING =================

  Future<void> _fetchAddressFromLatLng(LatLng latLng) async {
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

      final response = await http.get(
        url,
        headers: {'User-Agent': 'gratido-app'},
      );

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final address = data['address'];

      final parts = [
        address['road'],
        address['suburb'] ?? address['neighbourhood'],
        address['city'] ?? address['town'],
        address['state'],
      ];

      if (!mounted) return;

      setState(() {
        _addressText =
            parts.where((e) => e != null && e.toString().isNotEmpty).join(', ');
      });
    } finally {
      _isLoading = false;
    }
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
              initialCenter: _currentLocation ?? const LatLng(20, 78),
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

          /// 📍 FIXED CENTER MARKER (ZEPTO STYLE)
          const Center(
            child: IgnorePointer(child: _CenterMarker()),
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
                  suffixIcon: const Icon(Icons.tune),
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

          /// ⬆️ BOTTOM SHEET (OVERFLOW SAFE)
          _bottomSheet(),
        ],
      ),
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
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          constraints: const BoxConstraints(minHeight: 220),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 30,
                offset: Offset(0, -10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your Location",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(_addressText, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E5CD6),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _saveLocationAndExit,
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

  // ================= SAVE + EXIT =================

  Future<void> _saveLocationAndExit() async {
    if (_currentLocation == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('donor_lat', _currentLocation!.latitude);
    await prefs.setDouble('donor_lng', _currentLocation!.longitude);
    await prefs.setString('donor_address', _addressText);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DonorInterface()),
      (_) => false,
    );
  }
}

/// CENTER MARKER — UI UNCHANGED
class _CenterMarker extends StatelessWidget {
  const _CenterMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(blurRadius: 15, color: Colors.black26),
            ],
            image: const DecorationImage(
              image: AssetImage("assets/images/avatar.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
