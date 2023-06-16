import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sath_chalien_driver/infoHandler/app_info.dart';


import 'SplashScreen/splash_screen.dart';

void main()  async
{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MyApp(
        child:  ChangeNotifierProvider(
        create: (context) => AppInfo(),
          child: MaterialApp(
            title: 'Driver`s',
            theme: ThemeData(

              primarySwatch: Colors.blue,
            ),
            home:const MySplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        )
      ));
}


class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartapp(BuildContext context)
  {
    context.findAncestorStateOfType<_MyAppState>()!.restartapp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  void restartapp()
  {
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: key,
        child: widget.child!,
    );
  }
}
