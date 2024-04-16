import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aiassist/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sql_conn/sql_conn.dart';
import 'AdHelper.dart';

import 'about.dart';
import 'constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp1());

}






class MyApp1 extends StatefulWidget {
  @override
  _MyAppState1 createState() => _MyAppState1();
}
class _MyAppState1 extends State<MyApp1> {
  var dio = Dio();

  void request() async {
    Response response;
    response = await dio.get('https://isuruwe.pythonanywhere.com/get-token/');

    apikey=response.data.toString();
  }
  @override
  void initState() {
    super.initState();
    request();

  }
  @override
  void dispose() {

    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner: false,
      initialRoute: splash_screen.id,
      routes: {

        splash_screen.id: (context) => splash_screen(),

        about.id: (context) => about(),



      },
      title: 'AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('AI Assistant'),
        ),


      ),
    );
  }


}
