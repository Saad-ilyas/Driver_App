

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sath_chalien_driver/CarPool/Posts/search_places_screen.dart';
import 'package:sath_chalien_driver/global/global.dart';

import 'package:sath_chalien_driver/infoHandler/app_info.dart';
import 'package:sath_chalien_driver/infoHandler/app_info2.dart';
import 'package:sath_chalien_driver/widgets/customdialog.dart';
import 'package:sath_chalien_driver/widgets/mytext.dart';

import '../../assistants/assistant_methods.dart';
import '../../widgets/progress_dialog.dart';







class AddPostScreen extends StatefulWidget {

const  AddPostScreen({Key? key,}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  DateTime dateTime = DateTime.now();





  final formKey = GlobalKey<FormState>();

  TextEditingController priceController = TextEditingController();

  double bottomPaddingOfMap = 0;
  bool isContainerVisible3=false;
  void toggleContainerVisibility3() {
    setState(() {
      isContainerVisible3 = !isContainerVisible3;

    });

    // Start the timer
    if (isContainerVisible3) {
      Timer(Duration(seconds: 7), () {
        if (mounted) {
          setState(() {
            isContainerVisible3 = false;
          });
        }
      });
    }
    if (isContainerVisible3) {
      Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            isContainerVisible3 = false;
          });
        }
      });
    }
  }



  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  String location = 'Press icon to get location';
  String Address = '';
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address = ' ${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
    setState(() {});
  }
  var selectDate;
  var SelectTime;

  Future<void> drawPolyLineFromOriginToDestination() async
  {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context,
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

  final List<Map<String, dynamic>> seats = [
    {'seatNumber': "1", 'status': 'available','passengerName':'','passengerNumber':'','longitude':'','latitude':'',"email":'',"userId":''},
    {'seatNumber': "2", 'status': 'available','passengerName':'','passengerNumber':'','longitude':'','latitude':'',"email":'',"userId":''},
    {'seatNumber': "3", 'status': 'available','passengerName':'','passengerNumber':'','longitude':'','latitude':'',"email":'',"userId":''},
    // Add more seats as needed
  ];
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    String textValue = Provider.of<AppInfo2>(context).userDropOffLocation != null
        ? Provider.of<AppInfo2>(context).userDropOffLocation!.locationName!
        : "Drop-Off Location";
    var appSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);

            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          "Add your post",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.only(
                  left: appSize.width * 0.05, right: appSize.width * 0.05),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () async {
                          Position position = await _getGeoLocationPosition();
                          location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
                          GetAddressFromLatLong(position);
                        },
                        child: Container(
                            width: appSize.width,
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                            padding: EdgeInsets.all(6.0),
                            child: Icon(

                              Icons.add_location_alt,
                              color: Colors.red,
                              size: appSize.height * 0.04,
                            )),
                      ),
                    ),

                    Center(child: Text('Click the icon to get your location')),
                    SizedBox(height: 15,),

                    Text("My Location",style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: appSize.width*0.038
                    ),),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),

                   Container(
                     height: appSize.height*0.06,
                     width: appSize.width*0.9,
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(left: 5),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.black,width: 1.3),
                       borderRadius: BorderRadius.circular(7)
                     ),
                     child: Text(Address,style: TextStyle(color: Colors.black),),
                   ),
                    SizedBox(
                      height: appSize.height * 0.02,
                    ),
                    Text("Drop-Off Location",style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: appSize.width*0.038
                    ),),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () async
                      {
                        var responseFromSearchScreen =  await Navigator.push(context,MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));

                        if(responseFromSearchScreen == "obtainedDropoff")
                        {


                          await drawPolyLineFromOriginToDestination();



                        }
                      },
                      child:
                      Container(
                        height: appSize.height*0.06,
                        width: appSize.width*0.9,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black,width: 1.3),
                            borderRadius: BorderRadius.circular(7)
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.deepOrangeAccent,),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding:  EdgeInsets.only(top: appSize.height*0.017),

                                  child: Text(
                                      textValue,
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: appSize.height * 0.02,
                    ),
                    Row(
                      children: [
                        Text("Please enter amount",style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: appSize.width*0.038
                        ),),
                        SizedBox(width: 6,),
                        GestureDetector(
                            onTap: toggleContainerVisibility3,
                            child: Icon(Icons.info_outlined,color: Colors.black,size: 20,)),

                      ],
                    ),
                    Visibility(
                      visible: isContainerVisible3,
                      child: Center(
                        child: Container(
                          width: appSize.width*0.9,
                          padding: EdgeInsets.all(8.0),
                          color: Colors.black,
                          child: Text(
                            'I am pleased to inform you that the fare for a 25-kilometer journey will be priced at a reasonable rate of 1750 Rs. This cost-effective fare ensures that both passengers and drivers can enjoy a comfortable and convenient travel experience without burdening their wallets.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Container(
                      height: appSize.height * 0.08,
                      width: appSize.width * 0.9,
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: priceController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Please Enter fair"),
                        ]),
                        maxLines: 1,


                        style: TextStyle(
                          color: Colors.black,
                          fontSize: appSize.height * 0.018,
                        ),

                        //     controller: _email,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Total Fair (50_70 rs per km)',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: appSize.height * 0.018,
                          ),

                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.1), borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.1), borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Text("Date",style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: appSize.width*0.038
                    ),),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Container(
                      height: appSize.height * 0.07,
                      width: appSize.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,width: 1.3),
                          borderRadius: BorderRadius.circular(7)
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10,),
                          InkWell(
                              onTap: () async {
                                DateTime? selectedDate = await pickDate();
                                if (selectedDate != null) {
                                  setState(() {
                                    dateTime = selectedDate;
selectDate='${selectedDate.day}/${selectedDate.month}/${selectedDate.year
} ';
print(selectDate);
                                  });
                                }
                              },
                              child: Icon(Icons.calendar_today_outlined,color: Colors.deepOrange,size: 30,)),
                          SizedBox(width: 10,),
                          MyText(
                            text: '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                            textcolor: Colors.black,
                            fontSize: appSize.width * 0.04,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Text("DepartureTime",style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: appSize.width*0.038
                    ),),
                    SizedBox(
                      height: appSize.height * 0.01,
                    ),
                    Container(
                      height: appSize.height * 0.07,
                      width: appSize.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.3),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              await pickTime();
                            },
                            child: Icon(
                              Icons.access_time,
                              color: Colors.deepOrange,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 10),
                          MyText(
                            text: selectedTime.format(context),
                            textcolor: Colors.black,
                            fontSize: appSize.width * 0.04,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Seats",

                        style: TextStyle(

                        fontWeight: FontWeight.w600,
                            fontSize: appSize.width*0.038
                        ),),
                        SizedBox(width: 6,),
                        Text("3",style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: appSize.width*0.038
                        ),),

                      ],
                    ),

                    SizedBox(
                      height: appSize.height *  0.0,
                    ),
                    InkWell(
                      onTap: () async {
                        Customdialog.showDialogBox(context);
                        firebaseFirestore.collection("driverPost").add({

                          "startingPoint":Address,
                           "dropOffLocation":textValue,
                          "seats":seats,
                          "totalFare":priceController.text,
                          "driverName":onlineDriverData.name!,
                         "driverNumber":onlineDriverData.phone!,
                          "carNumber":onlineDriverData.car_number!,
                          "carModel":onlineDriverData.car_model!,
                          "carColor":onlineDriverData.car_color!,
                          "senderId":onlineDriverData.id!,
                          "Date":selectDate,
                          "departureTime": selectedTime.format(context),
                          "status":"pending",
                          "driverId":onlineDriverData.id!
                        }
                        ).then((value) {
                          print(selectDate);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: "Post added sucessfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: appSize.height * 0.04),
                        height: appSize.height * 0.07,
                        width: appSize.width * 0.88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),

                        ),
                        child: Text("Upload", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: appSize.width * 0.045
                        ),),
                      ),
                    ),
                    SizedBox(
                      height: appSize.height * 0.03,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<DateTime?> pickDate() => showDatePicker(
    context: context,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
    initialDate: dateTime,
  );





}
