import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:aiassist/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
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
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String id = 'myapp';
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showPlayer = false;
  String? audioPath;
  bool _isBannerAdReady = false;
  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  num get maxFailedLoadAttempts => 100;
  int cnt2=0;
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AdHelper.interstitialAdUnitId
            : AdHelper.interstitialAdUnitId,
        request:  AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);


          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
  @override
  void initState() {
    showPlayer = false;
    super.initState();

    requestPermissions();

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
    _createInterstitialAd();

  }
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

//   void sendMultipartRequest(String pth) async {
//     if(cnt2==5){
//       _showInterstitialAd();
//       cnt2=0;
//     }
//     else{
//       cnt2++;
//     }
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
//     );
//     request.headers['Authorization'] = 'Bearer b2RlbC5yZWFkIG1vZGVsLnJlcXVlc3Qgb3JnYWkVP6zOCzcTi9TzRroaiUvhMDgJLm246a9V4VUxCe1h0ACIKu_2PjSgWHLsSBQZWXbSFVwBiqnn4CSPfJlcXfQlImUf4z7DCPmkyTXQRKClLvYZLhXL2fQJ-tm3gj40PZU3VguY_mnSVygDcfICKWuteYYrdxcAY5rCtoYcsYeYaR1cQH0_u8ZyaJ5SOGL3-lJ53VsQDhmr4yoljSoPYl0w6c_6j3h9QbLYcYGZ0RTDJD4CpwoMpSMX7t4v3xcUndRJrBwK23L3bQUoK7lAx7OEjxJkdz7bRpw';
//
//
//     // Add a file to the request
//     var file = await http.MultipartFile.fromPath(
//       'file',
//       pth,
//       contentType: MediaType('audio', 'm4a'),
//     );
//     request.files.add(file);
//
//     // Add additional fields to the request
//     request.fields['model'] = 'whisper-1';
//
//     // Send the request
//     var response = await request.send();
//
//     // Get the response
//     if (response.statusCode == 200) {
//       var responseBody = await response.stream.bytesToString();
//       print('Upload successful!');
//       print('Response Body: $responseBody');
//       // var result = jsonDecode(responseBody);
//       try {
//         Map<String, dynamic> jsonMap = jsonDecode(responseBody);
//
//         if (jsonMap.containsKey('text')) {
//           String textValue = jsonMap['text'];
//           callstt(textValue);
//
//           print('Text value: $textValue');
//         } else {
//           print('The JSON does not contain a "text" parameter.');
//         }
//       } catch (ex) {
//         print('An error occurred while parsing the JSON: $ex');
//       }
//
// //         try {
// //           result[0].forEach((entry) {
// //           //String date = entry["dob"] != null ? entry["dob"].split("T")[0] : "";
// //           String text1 = entry["text"]!=null?entry["text"]:'';
// //           callstt(text1);
// //           });
// //         }
// //         catch (ex) {
// // print(ex.toString());
// //
// //         }
//
//
//
//     } else {
//       print('Upload failed with status code: ${response.statusCode}');
//     }
//   }

  void sendMultipartRequest(String pth) async {
    if(cnt2==5){
      _showInterstitialAd();
      cnt2=0;
    }
    else{
      cnt2++;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.deepgram.com/v1/listen'),
    );
    request.headers['Authorization'] = 'Token 824d6da305d25ab983004217097be199dfc42f8d';
    request.headers['content-type'] = 'audio/x-m4a';
    request.headers['accept'] = 'application/json';


    // Add a file to the request
    var file = await http.MultipartFile.fromPath(
      'data',
      pth,
      contentType: MediaType('audio', 'x-m4a'),
    );
    request.files.add(file);

    // Add additional fields to the request
   // request.fields['model'] = 'whisper-1';

    // Send the request
    var response = await request.send();

    // Get the response
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      print('Upload successful!');
      print('Response Body: $responseBody');
      // var result = jsonDecode(responseBody);
      try {

        Map<String, dynamic> jsonData = jsonDecode(responseBody);
        String transcript =
        jsonData['results']['channels'][0]['alternatives'][0]['transcript'];

        if(apikey!=""){
          callstt(transcript);
          //print(transcript);
        }
        else{
          showAlertDialog(context,"Error Occurred, Please restart App!");
        }



      } catch (ex) {
        print('An error occurred while parsing the JSON: $ex');
      }

//         try {
//           result[0].forEach((entry) {
//           //String date = entry["dob"] != null ? entry["dob"].split("T")[0] : "";
//           String text1 = entry["text"]!=null?entry["text"]:'';
//           callstt(text1);
//           });
//         }
//         catch (ex) {
// print(ex.toString());
//
//         }



    } else {
      print('Upload failed with status code: ${response.statusCode}');
    }
  }

  Future<String>  callstt(String msg) async {
    try{
    SSEClient.subscribeToSSE

      (

        method: SSERequestType.POST,
        url:
        'https://ai.fakeopen.com/api/conversation',
        header: {
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache",
          "Authorization": "Bearer $apikey",
    "Content-Type": "application/json"
        },
        body: {
          "action": "next",
          "messages": [
            {
              "id": "aaa26ef8-0237-496f-8c63-38406fc33771",
              "role": "user",
              "content": {
                "content_type": "text",
                "parts": ["$msg"]
              }
            }
          ],
          "model": "gpt-3.5-turbo",
          "parent_message_id": "19a12e23-5b5f-42cd-bf58-60a0f22dd635"
        }).listen((event) {
      print('Id: ' + event.id!);
      print('Event: ' + event.event!);
      print('Data: ' + event.data!);
      Map<String, dynamic> response = jsonDecode(event.data!);

      // Access the "parts" list
      List<dynamic> parts = response['message']['content']['parts'];

      // Convert the "parts" list to a single string
      String partsString = parts.join('\n');

      setState(() {
        quest=msg;
        answ= partsString;
        isLoading = false;
      });


    },

    );
    } catch (ex) {
     print('An error occurred while parsing the JSON: $ex');
    }
    return "";
  }
//   Future<String>  callstt(String msg) async {
//
// try {
//   var headers = {
//     'Authorization': 'Bearer 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',
//     'Content-Type': 'application/json',
//   };
//
//   // var data = '{"model": "whisper-1","file": "$path"';
//   var data = '{"model": "gpt-3.5-turbo","messages": [{"role": "user", "content": "$msg"}]}';
//
//   var url = Uri.parse('https://api.openai.com/v1/chat/completions');
//   var res = await http.post(url, headers: headers, body: data);
//   if (res.statusCode != 200) {
//     return res.statusCode.toString();
//   } else {
//     try {
//       Map<String, dynamic> jsonMap = jsonDecode(res.body);
//
//       List<dynamic> choices = jsonMap['choices'];
//       if (choices.isNotEmpty) {
//         String contentValue = choices[0]['message']['content'];
//         print('Content value: $contentValue');
//         setState(() {
//           quest = msg;
//           answ = contentValue;
//           isLoading = false;
//         });
//       } else {
//         print('No choices found in the JSON.');
//       }
//     } catch (ex) {
//       print('An error occurred while parsing the JSON: $ex');
//     }
//
//
//     print(res.body);
//     return res.body.toString();
//   }
// }catch(ex){
//
//   showAlertDialog(context,ex.toString());
//   return "";
// }
//   }


  showAlertDialog(BuildContext context ,String text) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  // Future<String>  getapi() async {
  //
  //   var url = Uri.parse('https://digitechnow.com/api/getapi/key');
  //   var res = await http.get(url);
  //   if (res.statusCode != 200) {
  //     return   res.statusCode.toString();
  //   }else{
  //
  //     print(res.body);
  //     return   res.body.toString();
  //   }
  //
  // }
  Future<void> requestPermissions() async {
    if (await Permission.microphone.request().isGranted&&await Permission.storage.request().isGranted    ) {
      // Either the permission was already granted before or the user just granted it.
    }
    else {
// You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.storage,
      ].request();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child:  AudioRecorder(
            onStop: (path) {
              if (kDebugMode) print('Recorded file path: $path');
              setState(() {
                sendMultipartRequest(path);
                audioPath = path;
                showPlayer = true;
              });
            },
          ),
        ),bottomNavigationBar: _buildBottomBar(),


    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: new Padding(
        padding: const EdgeInsets.all(1.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isBannerAdReady)
            //  Align(
            //   alignment: Alignment.bottomCenter,
            // child:
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),



          ],
        ),
      ),
    );
  }


}

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({Key? key, required this.onStop}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  TextEditingController _textEditingController = TextEditingController();
  List<String> _messages = [];
  int cnt1 = 0;


  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  num get maxFailedLoadAttempts => 100;
  var dio = Dio();

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));

    _createInterstitialAd();
    super.initState();
  }


  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        // final devs = await _audioRecorder.listInputDevices();
        // final isRecording = await _audioRecorder.isRecording();

        await _audioRecorder.start();
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);
      isLoading = true;
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      home: Scaffold(resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('AI Assistant'),
        ),
        drawer: SidebarX(
          controller: SidebarXController(selectedIndex: 0, extended: true),
          theme: SidebarXTheme(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            hoverColor: Colors.white,
            textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            selectedTextStyle: const TextStyle(color: Colors.white),
            itemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemTextPadding: const EdgeInsets.only(left: 30),
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue),
            ),
            selectedItemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blue.withOpacity(0.37),
              ),
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.cyanAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 30,
                )
              ],
            ),
            iconTheme: IconThemeData(
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 20,
            ),
          ),
          extendedTheme: const SidebarXTheme(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          //footerDivider: divider,
          headerBuilder: (context, extended) {
            return SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset('assets/logo.png'),
              ),
            );
          },
          footerBuilder: (context, extended) {
            return SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('V1.0 @2023', style: TextStyle(
                  color: Colors.white,)),
              ),
            );
          },


          items: [
            SidebarXItem(icon: Icons.home, label: 'Home', onTap: () {
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (_) => my()));

            },),
            SidebarXItem(icon: Icons.info, label: 'About', onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => about()));
            },),
          ],
        ),
        body: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  _buildRecordStopControl(),
                  const SizedBox(width: 20),
                  // _buildPauseResumeControl(),
                  // const SizedBox(width: 20),

                  _buildText(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(style: TextStyle(color: Colors.white),
                        controller: _textEditingController,
                        decoration: InputDecoration(hintStyle: TextStyle(
                            color: Colors.white),
                          hintText: 'Type a question...',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: Text('Ask'),
                    ),
                  ],
                ),
              ),
              //  if (_amplitude != null) ...[
              const SizedBox(height: 40),
              isLoading
                  ? CircularProgressIndicator() :
              Text('Question:' + quest + '\nAnswer:' + answ,
                style: TextStyle(fontSize: 20, color: Colors.white),),
              //  ],


            ],
          ),),
        ),),
    );
  }

  void _sendMessage() {
    String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        isLoading = true;
        if(apikey!=""){
          callstt2(message);
        }
        else{
          showAlertDialog(context,"Error Occurred, Please restart App!");
        }

      });
      _textEditingController.clear();
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AdHelper.interstitialAdUnitId
            : AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  showAlertDialog(BuildContext context, String text) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  // Future<String> callstt2(String msg) async {
  //   if (cnt1 == 5) {
  //     _showInterstitialAd();
  //     cnt1 = 0;
  //   }
  //   else {
  //     cnt1++;
  //   }
  //   var url = Uri.parse('https://ai.fakeopen.com/api/conversation');
  //   //  var formData = FormData.fromMap({"model": "gpt-3.5-turbo","messages": [{"role": "user", "content": "$msg"}]});
  //   var formData = FormData.fromMap({
  //     "action": "next",
  //     "messages": [
  //       {
  //         "id": "aaa26ef8-0237-496f-8c63-38406fc33771",
  //         "role": "user",
  //         "content": {
  //           "content_type": "text",
  //           "parts": ["$msg"]
  //         }
  //       }
  //     ],
  //     "model": "gpt-3.5-turbo",
  //     "parent_message_id": "19a12e23-5b5f-42cd-bf58-60a0f22dd635"
  //   });
  //
  //
  //   var opt = Options(headers: {
  //     'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1UaEVOVUpHT
  //   }, responseType: ResponseType.stream);
  //
  //   Response res = await dio.post<List<int>>(
  //     url.toString(), data: formData,
  //     options: Options(responseType: ResponseType
  //         .bytes), // Set the response type to `bytes`.
  //   );
  //   //Response res = await dio.post(url.toString(), data: formData,options: opt);
  //   print('Response status: ${res.statusCode}');
  //   print('Response body: ${res.data}');
  //   if (res.statusCode.toString() != '200') {
  //     return res.data;
  //   } else {
  //     try {
  //       Map<String, dynamic> jsonMap = jsonDecode(res.data);
  //
  //       List<dynamic> choices = jsonMap['choices'];
  //       if (choices.isNotEmpty) {
  //         String contentValue = choices[0]['message']['content'];
  //         print('Content value: $contentValue');
  //         setState(() {
  //           quest = msg;
  //           answ = contentValue;
  //           isLoading = false;
  //         });
  //       } else {
  //         print('No choices found in the JSON.');
  //       }
  //     } catch (ex) {
  //       print('An error occurred while parsing the JSON: $ex');
  //       showAlertDialog(context, ex.toString());
  //     }
  //     return res.data;
  //   }
  // }
  Future<String>  callstt2(String msg) async {
    try{
        if (cnt1 == 5) {
          _showInterstitialAd();
          cnt1 = 0;
        }
        else {
          cnt1++;
        }
  SSEClient.subscribeToSSE

  (

  method: SSERequestType.POST,
  url:
  'https://ai.fakeopen.com/api/conversation',
  header: {
  "Accept": "text/event-stream",
  "Cache-Control": "no-cache",
   "Authorization": "Bearer $apikey",
         "Content-Type": "application/json"
  },
  body: {
      "action": "next",
      "messages": [
        {
          "id": "aaa26ef8-0237-496f-8c63-38406fc33771",
          "role": "user",
          "content": {
            "content_type": "text",
            "parts": ["$msg"]
          }
        }
      ],
      "model": "gpt-3.5-turbo",
      "parent_message_id": "19a12e23-5b5f-42cd-bf58-60a0f22dd635"
    }).listen((event) {
  print('Id: ' + event.id!);
  print('Event: ' + event.event!);
  print('Data: ' + event.data!);
  Map<String, dynamic> response = jsonDecode(event.data!);

  // Access the "parts" list
  List<dynamic> parts = response['message']['content']['parts'];

  // Convert the "parts" list to a single string
  String partsString = parts.join('\n');

  setState(() {
              quest=msg;
              answ= partsString;
              isLoading = false;
            });


  },

  );
    } catch (ex) {
      print('An error occurred while parsing the JSON: $ex');
    }
  return "";
}
  // Future<String>  callstt2(String msg) async {
  //   try{
  //   if(cnt1==5){
  //     _showInterstitialAd();
  //     cnt1=0;
  //   }
  //   else{
  //     cnt1++;
  //   }
  //   var headers = {
  //     'Authorization': 'Bearer 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',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   // var data = '{"model": "whisper-1","file": "$path"';
  //   var data = '{"model": "gpt-3.5-turbo","messages": [{"role": "user", "content": "$msg"}]}';
  //
  //   var url = Uri.parse('https://api.openai.com/v1/chat/completions');
  //   var res = await http.post(url, headers: headers, body: data);
  //   if (res.statusCode != 200) {
  //     return   res.statusCode.toString();
  //   }else{
  //
  //     try {
  //       Map<String, dynamic> jsonMap = jsonDecode(res.body);
  //
  //       List<dynamic> choices = jsonMap['choices'];
  //       if (choices.isNotEmpty) {
  //         String contentValue = choices[0]['message']['content'];
  //         print('Content value: $contentValue');
  //         setState(() {
  //           quest=msg;
  //           answ= contentValue;
  //           isLoading = false;
  //         });
  //       } else {
  //         print('No choices found in the JSON.');
  //       }
  //     } catch (ex) {
  //       print('An error occurred while parsing the JSON: $ex');
  //
  //     }
  //
  //
  //
  //
  //
  //
  //     print(res.body);
  //     return   res.body.toString();
  //   }
  //   }catch(ex){
  //
  //     showAlertDialog(context,ex.toString());
  //     return "";
  //   }
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Click mic icon to Ask AI",style:TextStyle(color: Colors.white));
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
