import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';


import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../infohandler/app_info.dart';
import '../tabPages/search_places_screen.dart';
import '../widgets/progress_dialog.dart';




class showlocation extends StatefulWidget {
  const showlocation({Key? key}) : super(key: key);

  @override
  State<showlocation> createState() => _showlocationState();
}

class _showlocationState extends State<showlocation> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  Position? userCurrentPosition;
  String userName = "";
  String userEmail = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _passengerCount;
  String? _rideType;
  GoogleMapController? newGoogleMapController;
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _passengerCount = 2;
    _rideType = 'Bike';
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

  }

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  double bottomPaddingOfMap = 0;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 25,
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  validateinfo() {
    if (Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation != null) {
      savecarpoolinfo();
    }
    else {
      Fluttertoast.showToast(msg: "Please select a destination location");
    }
  }
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime!,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }


  void savecarpoolinfo() {

    DatabaseReference? RideRequestdriver = FirebaseDatabase.instance.ref().child(
        "carpoolformdriver").push();

    var originLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;
    var destinationLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;

    Map originLocationMap =
    {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap =
    {
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString(),
    };

    Map driverInformationMap = {

      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "Dateoftravel": DateTime.now().toString(),
      "Timeoftravel": TimeOfDay.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,


    };
    RideRequestdriver!.set(driverInformationMap);
    // Reset form fields

    Fluttertoast.showToast(msg: "Form submitted");

    setState(() {
      destinationLocation.locationName == null;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _passengerCount = 2;
      _rideType = 'Bike';
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locateDriverPosition();

              setState(() {
                bottomPaddingOfMap = 240;
              });

            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 400,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),

              child:Container(
                color: Colors.blueGrey.shade700,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,


                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 12),
                      child: Row(
                        children: [


                          const Icon(
                            Icons.location_on_rounded, color: Colors.deepOrangeAccent,),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation != null
                                    ? "${(Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!).substring(0, 45)}..."
                                    : "Pick-up Location",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 22.0),
                    GestureDetector(
                      onTap: () async
                      {
                        var responseFromSearchScreen = await Navigator.push(context,
                            MaterialPageRoute(builder: (c) => SearchPlacesScreen()));

                        if (responseFromSearchScreen == "obtainedDropoff") {
                          setState(() {

                          });

                          await drawPolyLineFromOriginToDestinationCarpool();

                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded, color: Colors.deepOrangeAccent,),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  Provider
                                      .of<AppInfo>(context)
                                      .userDropOffLocation != null
                                      ? Provider
                                      .of<AppInfo>(context)
                                      .userDropOffLocation!
                                      .locationName!
                                      : "Drop-Off Location",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),



                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text('Date of Departure:', style: TextStyle(color: Colors.white,),),
                          SizedBox(width: 16.0),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              '${_selectedDate!.day}/${_selectedDate!
                                  .month}/${_selectedDate!.year}', style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text('Time of Departure:', style: TextStyle(color: Colors.white,),),
                          SizedBox(width: 16.0),
                          TextButton(
                            onPressed: () => _selectTime(context),
                            child: Text('${_selectedTime!.format(context)}',style: TextStyle(color: Colors.deepOrangeAccent),),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text('No. of Passengers:' ,style: TextStyle(color: Colors.white,),),
                          SizedBox(width: 16.0),
                          DropdownButton<int>(
                            value: _passengerCount,
                            onChanged: (value) {
                              setState(() {
                                _passengerCount = value;
                              });
                            },
                            items: [2, 3, 4]
                                .map((count) =>
                                DropdownMenuItem<int>(
                                  value: count,
                                  child: Text('$count',style: TextStyle(color: Colors.yellowAccent,),),
                                ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text('Type of Ride:', style: TextStyle(color: Colors.white,),),
                          SizedBox(width: 16.0),
                          DropdownButton<String>(
                            value: _rideType,
                            onChanged: (value) {
                              setState(() {
                                _rideType = value;
                              });
                            },
                            items: ['Bike', 'Ride-Ac', 'Ride-Mini']
                                .map((type) =>
                                DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type,style: TextStyle(color: Colors.yellowAccent,),),
                                ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent, // Set the desired color here
                      ),
                      onPressed:savecarpoolinfo,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> drawPolyLineFromOriginToDestinationCarpool() async
  {
    var originPosition = Provider.of<AppInfo>(context , listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context , listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context ,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        width: 5,
        color: Colors.redAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }
}

