import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'MyApp.dart';
import 'main.dart';





class splash_screen extends StatefulWidget {
  static const String id = 'splash_screen';
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<splash_screen> {

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    startTime();

  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: initScreen(context),
    ),);
  }
  Future<void> checkIfUserExists() async {


      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyApp()));

  }
  startTime() async {
    var duration = new Duration(seconds: 6);
    return new Timer(duration, checkIfUserExists);
  }



  initScreen(BuildContext context) {
    return Scaffold(
      body:

      Container(
          decoration: BoxDecoration(
            //color: Colors.pinkAccent,
            image: DecorationImage(
              fit: BoxFit.fill,
             // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
             image: AssetImage("assets/start.png"),

             // image: Image.asset('assets/images/pikachu.png').image,
            ),
          ),


        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Container(
            //   child:  Image.asset("assets/images/start.png"),
            // ),


            // Padding(padding: EdgeInsets.only(top: 20.0)),
            // CircularProgressIndicator(
            //   backgroundColor: Colors.white,
            //   strokeWidth: 1,
            // )
          ],
        ),
      ),
    );
  }
}
