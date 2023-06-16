


import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sath_chalien_driver/models/driver_data.dart';

import '../models/direction_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

DirectionDetailsInfo? tripDirectionDetailsInfo;
User? currentFirebaseUser;
String userDropOffAddress = "";
DriverData? userModelCurrentInfo;
StreamSubscription<Position>? streamsubscriptionPosition;
StreamSubscription<Position>? streamsubscriptionDriverLivePosition;
AssetsAudioPlayer audioPlayer =AssetsAudioPlayer();
Position? driverCurrentPosition;
DriverData onlineDriverData = DriverData();
String? driverVehicleType = "";
String titleStarsRating = "Good";
