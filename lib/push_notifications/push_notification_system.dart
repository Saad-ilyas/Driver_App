import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sath_chalien_driver/global/global.dart';
import 'package:sath_chalien_driver/models/passengereiderequest_information.dart';
import 'package:sath_chalien_driver/push_notifications/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future initializeCloudMessaging(BuildContext context) async {
    //  Terminate
    //  when app is completely closed and opened directly from push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        print(remoteMessage.data["rideRequestId"]);
        readpassengerRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });

    //  ForeGround
    //    when app is open and it receive a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      print(remoteMessage!.data["rideRequestId"]);
      readpassengerRideRequestInformation(
          remoteMessage.data["rideRequestId"], context);
    });

    //  BackGround
    //   when app is in the background and opened directly from push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      print(remoteMessage!.data["rideRequestId"]);
      readpassengerRideRequestInformation(
          remoteMessage.data["rideRequestId"], context);
    });
  }

  readpassengerRideRequestInformation(
      String passegerRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(passegerRideRequestId)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        audioPlayer.open(Audio("music/music_notification.mp3"));
        audioPlayer.play();

        double originlat = double.parse(
            (snapData.snapshot.value! as Map)["origin"]["latitude"].toString());
        double originlng = double.parse(
            (snapData.snapshot.value! as Map)["origin"]["longitude"]
                .toString());
        String originAddress =
            (snapData.snapshot.value! as Map)["originAddress"];

        double destinationlat = double.parse(
            (snapData.snapshot.value! as Map)["destination"]["latitude"]
                .toString());
        double destinationlng = double.parse(
            (snapData.snapshot.value! as Map)["destination"]["longitude"]
                .toString());
        String destinationAddress =
            (snapData.snapshot.value! as Map)["destinationAddress"];

        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

        String? rideRequestId = snapData.snapshot.key;

        passengerRideRequestInformation userRideRequestDetails =
            passengerRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originlat, originlng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng =
            LatLng(destinationlat, destinationlng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        userRideRequestDetails.rideRequestId = rideRequestId;


        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "This Ride Request Id do no exists");
      }
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    FirebaseDatabase.instance
        .ref()
        .child("Driver")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
