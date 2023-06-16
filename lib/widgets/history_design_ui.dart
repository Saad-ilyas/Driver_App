import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sath_chalien_driver/models/trip_history_model.dart';




class HistoryDesignUIWidget extends StatefulWidget
{
  TripsHistoryModel? tripsHistoryModel;

  HistoryDesignUIWidget({this.tripsHistoryModel});

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}




class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget>
{
  String formatDateAndTime(String dateTimeFromDB)
  {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    // Dec 10                            //2022                         //1:12 pm
    String formattedDatetime = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDatetime;
  }

  @override
  Widget build(BuildContext context)
  {
    return Container(
      color: Colors.blueGrey.shade800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //driver name + Fare Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    "Passenger : " + widget.tripsHistoryModel!.userName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12,),

                Text(
                  "\$ " + widget.tripsHistoryModel!.fareAmount!,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2,),

            // car details
            Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 24,
                ),

                const SizedBox(width: 12,),

                Text(
                  widget.tripsHistoryModel!.userPhone!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20,),

            //icon + pickup
            Row(
              children: [

                Image.asset(
                  "images/origin.png",
                  height: 26,
                  width: 26,
                ),

                const SizedBox(width: 12,),

                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.originAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 14,),

            //icon + dropOff
            Row(
              children: [

                Image.asset(
                  "images/destination.png",
                  height: 24,
                  width: 24,
                ),

                const SizedBox(width: 12,),

                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.destinationAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 14,),

            //trip time and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2,),

          ],
        ),
      ),
    );
  }
}
