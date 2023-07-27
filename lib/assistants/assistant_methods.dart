import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/driver_data.dart';
import '../models/trip_history_model.dart';
import 'request_assistant.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$MapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions PickUpAddress = Directions();
      PickUpAddress.locationLatitude = position.latitude;
      PickUpAddress.locationLongitude = position.longitude;
      PickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(PickUpAddress);
    }

    return humanReadableAddress;
  }


  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$MapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference driversRef = FirebaseDatabase.instance
        .ref()
        .child("Driver")
        .child(currentFirebaseUser!.uid);

    driversRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        userModelCurrentInfo = DriverData.fromSnapshot(snap.snapshot);
      }
    });
  }
  static pauseLiveLocationUpdate() {
    streamsubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdate() {
    streamsubscriptionPosition!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

//RS
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double usdtopkrconverter = totalFareAmount*270;
    if (driverVehicleType == "bike") {
      double resultFareAmount = totalFareAmount.truncate() as double;
      return resultFareAmount;
    } else if (driverVehicleType == "Ride-Ac") {
      double resultFareAmount = (totalFareAmount.truncate()) / 2.5;
      return resultFareAmount;
    } else if (driverVehicleType == "Ride-Mini") {
      double resultFareAmount = (totalFareAmount.truncate()) * 1.2 ;
      return resultFareAmount;
    } else {
      return double.parse(usdtopkrconverter.toStringAsFixed(1));
    }
  }


  //retrieve the trips KEYS for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineDriver(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value)
        {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context)
  {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys)
    {
      FirebaseDatabase.instance.ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended")
        {
          //update-add each history to OverAllTrips History Data List
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  //readDriverEarnings
  static void readDriverEarnings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("Driver")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripsKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context)
  {  FirebaseDatabase.instance.ref()
      .child("Driver")
      .child(fAuth.currentUser!.uid)
      .child("ratings")
      .once()
      .then((snap)
  {
    if(snap.snapshot.value != null)
    {
      String driverRatings = snap.snapshot.value.toString();
      Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
    }
  });

  }

}