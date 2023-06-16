import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';

class Ratings extends StatefulWidget {
  const Ratings({Key? key}) : super(key: key);

  @override
  State<Ratings> createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  double ratingsNumber = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getRatingsNumber();
  }

  getRatingsNumber() {
    setState(() {
      ratingsNumber = double.parse(
          Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingsNumber == 1) {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
    if (ratingsNumber == 2) {
      setState(() {
        titleStarsRating = "Bad";
      });
    }
    if (ratingsNumber == 3) {
      setState(() {
        titleStarsRating = "Good";
      });
    }
    if (ratingsNumber == 4) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    }
    if (ratingsNumber == 5) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22.0,
              ),
              const Text(
                "Your Ratings",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              const Divider(
                height: 4.0,
                thickness: 4.0,
                color: Colors.white,
              ),
              const SizedBox(
                height: 22.0,
              ),
              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.yellowAccent,
                borderColor: Colors.yellowAccent,
                size: 35,
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
