// lib/features/receiver/address_pick_result.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressPickResult {
  final LatLng position;
  final String addressLine1;
  final String addressLine2;
  final String buildingDetails;

  AddressPickResult({
    required this.position,
    required this.addressLine1,
    required this.addressLine2,
    required this.buildingDetails,
  });
}
