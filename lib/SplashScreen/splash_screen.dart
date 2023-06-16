import 'dart:async';
import 'package:sath_chalien_driver/authentication/signup_screen.dart';
import 'package:sath_chalien_driver/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if(await fAuth.currentUser != null){
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MainScreen()));

      }
      else{
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => Login()));

      }

    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 270,
                height: 300,
                child: ClipRRect(
                  child: Image.asset('images/Logooo.png'),
                ),
              ),
            const  SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const   Text(
                    'Sath ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const  Text(
                    'Chalein',
                    style: TextStyle(
                      color: Colors.limeAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const  SizedBox(
                height: 5,
              ),
              const   Text(
                'Sharing Adventures Together',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
