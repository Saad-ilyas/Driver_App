import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverInformation {
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;
  DriverInformation({
    this.originLatLng,
    this.destinationLatLng,
    this.destinationAddress,
    this.originAddress,
    this.userName,
    this.userPhone,
    this.rideRequestId,
  });
}
