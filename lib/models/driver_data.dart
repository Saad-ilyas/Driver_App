import 'package:firebase_database/firebase_database.dart';

class DriverData
{
  String? id;
  String? name;
  String? phone;
  String? email;
  String? car_color;
  String? car_model;
  String? car_number;

  DriverData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.car_color,
    this.car_model,
    this.car_number,
});


  DriverData.fromSnapshot(DataSnapshot snap)
  {
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    id = snap.key;
    email = (snap.value as dynamic)["email"];
  }
 }