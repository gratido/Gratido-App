import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class ReceiverLocationPage extends StatefulWidget {
  const ReceiverLocationPage({super.key});

  @override
  State<ReceiverLocationPage> createState() => _ReceiverLocationPageState();
}

class _ReceiverLocationPageState extends State<ReceiverLocationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
    setState(() {
      _currentLocation = LatLng(data.latitude!, data.longitude!);
    });

    _mapController.move(_currentLocation!, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌍 OpenStreetMap background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(20, 78),
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 70,
                      height: 70,
                      child: _avatarMarker(),
                    ),
                  ],
                ),
            ],
          ),

          /// 🔍 Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _searchBar(),
          ),

          /// 📍 Right floating buttons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                _mapButton(Icons.my_location, _getCurrentLocation),
                const SizedBox(height: 12),
                _mapButton(Icons.layers),
              ],
            ),
          ),

          /// ⬆️ Bottom sheet
          _bottomSheet(),
        ],
      ),
    );
  }

  /// Avatar marker like your design
  Widget _avatarMarker() {
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
              BoxShadow(
                blurRadius: 15,
                color: Colors.black26,
              )
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
        )
      ],
    );
  }

  Widget _searchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
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
    );
  }

  Widget _mapButton(IconData icon, [VoidCallback? onTap]) {
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
      child: Container(
        height: 260,
        padding: const EdgeInsets.all(24),
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
              "Your Location",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Set your precise pickup point for the donation",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                // Save location & continue
              },
              child: const Text(
                "Confirm Location →",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
