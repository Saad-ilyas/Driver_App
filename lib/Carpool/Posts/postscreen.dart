import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sath_chalien_driver/CarPool/Posts/updatepostscreen.dart';
import 'package:sath_chalien_driver/global/global.dart';
import 'package:sath_chalien_driver/widgets/mytext.dart';

import '../../infoHandler/app_info.dart';
import 'addpostscreen.dart';

class SeatDisplayScreen extends StatefulWidget {
  @override
  State<SeatDisplayScreen> createState() => _SeatDisplayScreenState();
}

class _SeatDisplayScreenState extends State<SeatDisplayScreen> {
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
          "Driver Post",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>  AddPostScreen(



          )));
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('driverPost').where("senderId",isEqualTo: fAuth.currentUser!.uid).where("status", isEqualTo: "pending").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }


          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final documentData = documents[index];
              final startingPoint = documentData['startingPoint'];
              final dropOffLocation = documentData['dropOffLocation'];
              final totalFare = documentData['totalFare'];
              final driverName = documentData['driverName'];
              final driverNumber = documentData['driverNumber'];
              final carNumber = documentData['carNumber'];
              final carModel = documentData['carModel'];
              final carColor = documentData['carColor'];
              final date = documentData['Date'];
              final time = documentData['departureTime'];
              final seatData = documentData['seats'] as List;


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
                            Text(driverName),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>  UpdatePostScreen(
id: documentData.id,
                                  fare: totalFare,


                                )));
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Icon(Icons.edit,color: Colors.white,)),
                            ),

                            SizedBox(width: 6,),
                            GestureDetector(
                              onTap: ()async{
                                await firebaseFirestore.collection("driverPost").doc(documentData.id).delete();

                              },
                              child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.red,

                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Icon(Icons.delete,color: Colors.white,)),
                            )
                          ],
                        )
                      ],
                    ),
                    ListTile(

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5,),

                          MyText(text:'Starting Point: $startingPoint',textcolor: Colors.black,),
                          MyText(text:'Drop-off Location: $dropOffLocation',textcolor: Colors.black,),
                          MyText(text:'Total Fare: $totalFare',textcolor: Colors.black,),

                          MyText(text:'Driver Number: $driverNumber',textcolor: Colors.black,),
                          MyText(text:'Car Number: $carNumber',textcolor: Colors.black,),
                          MyText(text:'Car Model: $carModel',textcolor: Colors.black,),
                          MyText(text:'Car Color: $carColor',textcolor: Colors.black,),
                          MyText(text:'Date: $date',textcolor: Colors.black,),
                          MyText(text:'DepartureTime: $time',textcolor: Colors.black,),

                          SizedBox(height: 8,),
                          MyText(text:'Seat Detail',textcolor: Colors.black,fontWeight: FontWeight.w500,fontSize: 16,),
                          SizedBox(height: 4,),
                        ],
                      ),

                    ),


                    Container(
                      height: 100,


                      child: ListView.builder(
                        itemCount:seatData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {

                          var seat = seatData[index];
                          final seatNumber = seat['seatNumber'];
                          final seatStatus = seat['status'];
                          Color seatColor = Colors.orange; // Default color for available seats
                          if (seatStatus == 'booked') {
                            seatColor = Colors.red;
                          }

                          return Container(

                            child: Row(
                              children: [
                                SizedBox(width: appSize.width*0.12,),
                                Column(
                                  children: [
                                    SizedBox(height: 5,),
                                    Stack(
                                      children: [
                                        Image.asset("images/seat.png", scale: 10, color: seatColor),
                                        Positioned(
                                            top: appSize.height*0.02,
                                            left: appSize.width*0.035,
                                            child: Text(seatNumber,style: TextStyle(
                                              color: Colors.white,fontSize: 11
                                            ),)),
                                      ],
                                    ),
                                    Text(seatStatus),
                                  ],
                                ),

                              ],
                            ),
                          );

                        },
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await firebaseFirestore.collection("driverPost").doc(documentData.id).update({
                          "status":"active"
                        }).then((value) {
                          setState(() {
                            status = "active"; // Update the 'status' variable
                            isButtonVisible = false;
                          });

                          Navigator.pop(context);

                          Fluttertoast.showToast(
                              msg: "Trip Started",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        });
                      },
                      child:  Center(
                        child: Container(
                          margin: EdgeInsets.only(top: appSize.height * 0.01,bottom: 10),
                          height: appSize.height * 0.07,
                          width: appSize.width * 0.6,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),

                          ),
                          child: Text("Start the trip", style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: appSize.width * 0.045
                          ),),
                        ),
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