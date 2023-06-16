import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../infoHandler/app_info.dart';
import '../mainScreens/trips_history_screen.dart';


class Earning extends StatefulWidget {
  const Earning({Key? key}) : super(key: key);

  @override
  _EarningState createState() => _EarningState();
}



class _EarningState extends State<Earning> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(
        children: [

          //earnings
          Container(
            color: Colors.blueGrey[900],
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [

                  const Text(
                    "Your Earnings:",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Text(
                    "Rs " + Provider.of<AppInfo>(context, listen: false).driverTotalEarnings,
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
          ),

          //total number of trips
          ElevatedButton(
            onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));
            },
            style: ElevatedButton.styleFrom(
                primary: Colors.white54
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [

                  Image.asset(
                    "images/car_logo.png",
                    width: 70,
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  const Text(
                    "Total Trips! ",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  Expanded(
                    child: Container(
                      child: Text(
                        Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
