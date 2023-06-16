import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sath_chalien_driver/global/global.dart';

import '../SplashScreen/splash_screen.dart';

class CarInfoScreen extends StatefulWidget {
  @override
  _CarInfoScreenState createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  List<String> carTypesList = ["Ride-Ac", "Ride-Mini", "Bike"];
  String? selectedCarType;

  saveCarInfo() {
    Map driverCarInfoMap = {
      "car_color": carColorTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "car_model": carModelTextEditingController.text.trim(),
      "type": selectedCarType,
    };

    DatabaseReference driversRef =
        FirebaseDatabase.instance.ref().child("Driver");
    driversRef
        .child(currentFirebaseUser!.uid)
        .child("car_details")
        .set(driverCarInfoMap);

    Fluttertoast.showToast(msg: "Car Details has been saved, Congratulations.");
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar
          (
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          bottom: TabBar
            (
            indicator: BoxDecoration
              (
                borderRadius: BorderRadius.circular(5), // Creates border
                color:
                    Colors.blueGrey[700]), //Change background color from here
            tabs: [
              Tab
                (
                text: 'Enter your car details',
              ),
            ],
          ),
        ),
        body: ListView
          (
          padding: EdgeInsets.all(20),
          children: [
            SizedBox
              (
              height: 22,
            ),

            // Car Model
            Container
              (
              width: 350,
              height: 40,
              child: TextField(
                controller: carModelTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Car Model*',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.add,
                    color: Colors.black54,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox
              (
              height: 22,
            ),
            // car Number
            Container
              (
              width: 350,
              height: 40,
              child: TextField(
                controller: carNumberTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Car Number*',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.add,
                    color: Colors.black54,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder
                    (
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder
                    (
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox
              (
              height: 22,
            ),

            //Car color
            Container
              (
              width: 350,
              height: 40,
              child: TextField(
                controller: carColorTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Car Color*',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.add,
                    color: Colors.black54,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 22,
            ),

            //Car Type

            Padding
            (
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Type*',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  DropdownButton
                    (
                    dropdownColor: Colors.blueGrey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    value: selectedCarType,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCarType = newValue.toString();
                      });
                    },
                    items: carTypesList.map((car) {
                      return DropdownMenuItem(
                        child: Text(
                          car,
                        ),
                        value: car,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            //button
            ElevatedButton
              (
              onPressed: () {
                if (carColorTextEditingController.text.isNotEmpty &&
                    carNumberTextEditingController.text.isNotEmpty &&
                    carModelTextEditingController.text.isNotEmpty &&
                    selectedCarType != null) {
                  saveCarInfo();
                }
              },


              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[800],
              ),

              child: const Text(
                "SignIn",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
