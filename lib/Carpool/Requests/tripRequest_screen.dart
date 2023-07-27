import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sath_chalien_driver/global/global.dart';
import 'package:sath_chalien_driver/widgets/mytext.dart';
import '../../infoHandler/app_info.dart';


class RequestScreen extends StatefulWidget {
  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool? isButtonVisible;
  String? status;
  @override
  void initState() {
    super.initState();
    isButtonVisible = true;
    status = ""; // Initialize status to an empty string
    // Retrieve the status from the database and update the 'status' variable
    // using setState or any other method you use to fetch data.
  }
  @override
  Widget build(BuildContext context) {
    var appSize = MediaQuery.of(context).size;
    return Scaffold(
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
          "REQUESTS",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orderRequest').where("driverId",isEqualTo: fAuth.currentUser!.uid).where("status",isEqualTo: "pending").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No request available'));
          }


          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
             var documentData = documents[index];

var ds=documentData.id;

              return Container(
                margin: EdgeInsets.only(left: appSize.width*0.03,right:appSize.width*0.03,top: appSize.height*0.01 ),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 5,),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                  "images/driver.png"
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(documentData.get("passengerName")),
                          ],
                        ),

                      ],
                    ),
                    ListTile(

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5,),
                          MyText(text:'Passeenger Email: ${documentData.get("email")}',textcolor: Colors.black,),
                          MyText(text:'Passeenger Number: ${documentData.get("passengerNumber")}',textcolor: Colors.black,),
                          MyText(text:'Seat Number: ${documentData.get("seatNumber")}',textcolor: Colors.black,),
                          MyText(text:'Starting Point:${documentData.get("startingPoint")}',textcolor: Colors.black,),
                          MyText(text:'Drop-off Location: ${documentData.get("dropOff")}',textcolor: Colors.black,),
                          MyText(text:'Fare: ${documentData.get("userFare")}',textcolor: Colors.black,),
                          MyText(text:'Longitude: ${documentData.get("longitude")}',textcolor: Colors.black,),
                          MyText(text:'Latitude: ${documentData.get("latitude")}',textcolor: Colors.black,),
                          SizedBox(height: appSize.height*0.02,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async{
                                  await firebaseFirestore.collection("orderRequest").doc(ds).update({

                                    "status":"accept",

                                  }).then((value) => {
                                    Fluttertoast.showToast(
                                        msg: "Post Accepted",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    ),
                                    Navigator.pop(context),
                                  });

                                },
                                child: Container(
                                  height: appSize.height * 0.064,
                                  width: appSize.width * 0.35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: appSize.width * 0.045),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async{
                                  await firebaseFirestore.collection("orderRequest").doc(ds).update({

                                    "status":"rejected",

                                  }).then((value) => {
                                  Fluttertoast.showToast(
                                  msg: "Post Rejected",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                                  ),
                                    Navigator.pop(context),
                                  });

                                },
                                child: Container(
                                  height: appSize.height * 0.064,
                                  width: appSize.width * 0.35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    "Reject",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: appSize.width * 0.045),
                                  ),
                                ),
                              )
                            ],
                          ),






                        ],
                      ),

                    ),




                  ],
                ),
              );
            },
          );
        },
      ),

    );
  }
}