import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sath_chalien_driver/push_notifications/push_notification_system.dart';
import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../mainScreens/carool_screen_driver.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            driverCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);
    AssistantMethods.readDriverRatings(context);
  }
  double bottomPaddingOfMap = 0;
  readCurrentDriverInformation() async {
    currentFirebaseUser = fAuth.currentUser;
    await FirebaseDatabase.instance
        .ref()
        .child("Driver")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.car_color =
            (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model =
            (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number =
            (snap.snapshot.value as Map)["car_details"]["car_number"];
        driverVehicleType = (snap.snapshot.value as Map)["car_details"]["type"];
        print("Car Details :: ");
        print(onlineDriverData.car_color);
        print(onlineDriverData.car_model);
        print(onlineDriverData.car_number);
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
    AssistantMethods.readDriverEarnings(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     key: sKey,
     body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              //for black theme google map
              // blackThemeGoogleMap(newGoogleMapController);
              locateDriverPosition();
              setState(() {
                bottomPaddingOfMap = 240;
              });
            },
          ),
          //  UI for online/offline driver
          statusText != "Now Online"
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : Container(),
          //   Button for online/offline
          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.45
                : 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isDriverActive != true) {
                      driverIsOnlineNow();
                      updateDriversLocationatRealtime();
                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });
                      //Display Text
                      Fluttertoast.showToast(msg: "You are online now");
                    } else {
                      driverisOfflineNow();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });
                      //Display  text
                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ],
            ),
          ),
          //Carpool
          Positioned(
            top:90,
            left:30 ,
            child:
            ElevatedButton(

              child: const Text(
                  "Car Pool",
                  style:TextStyle(
                    color: Colors.white,
                  )

              ),
              onPressed: ()
              {

                Navigator.push(context,MaterialPageRoute(builder: (c)=> const showlocation()));


              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  textStyle: const TextStyle( fontSize: 13, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        //  Post Schedule
          Positioned(


            top: 100,
            left:250,
            child:
            ElevatedButton(

              child: const Text(
                  "View Passenger \n Schedule",
                  style:TextStyle(
                    color: Colors.white,
                  )

              ),
              onPressed: ()
              {

              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  textStyle: const TextStyle( fontSize: 13, fontWeight: FontWeight.bold)
              ),
            ),



          ),

        ],
      ),
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("Driver")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    //Searching for Ride Request
    ref.set("idle");
    ref.onValue.listen((event) {});
  }

  updateDriversLocationatRealtime() async {
    streamsubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverisOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("Driver")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(const Duration(milliseconds: 2000), () {
      // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
