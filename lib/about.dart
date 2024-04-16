import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




import 'FancyContainer2.dart';





class about extends StatefulWidget {


  static const String id = 'about';

  @override
  _about createState() => _about();
}

class _about extends State<about> {

  final Uri _url = Uri.parse('https://docs.google.com/document/d/1iTHBaCfnXppkwSG66l4gCNUWZJb3TsHA/edit?usp=sharing&ouid=107822574984842832627&rtpof=true&sd=true');

        @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body:  Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child:SingleChildScrollView(
        child:
        Column(

            children: <Widget>[
              new Divider(
                color: Colors.blue,
              ),
              const FancyContainer2(width: double.maxFinite,height: 190,
                  title: '',
                  color1: Colors.lightGreenAccent,
                  color2: Colors.lightBlue,

                  subtitle: 'AI Assistant is a cutting-edge chat application powered by GPT-3.5 Turbo AI technology. It serves as a virtual assistant, providing users with a seamless and intelligent conversational experience. Whether you need assistance with information retrieval, task automation, or simply engaging in a natural language conversation, AI Assistant is here to help.'
                  '\n Experience the power of AI Assistant and unlock the potential of advanced AI technology in the palm of your hand. Let AI Assistant be your knowledgeable and reliable virtual companion, always ready to assist and engage in insightful conversations.'
                      '\n Contact us if any complains on : jayaaliwithanage@gmail.com' ),
              new Divider(
                color: Colors.blue,
              ),
              ElevatedButton(
                onPressed: _launchUrl,
                child: Text('Privacy Policy'),
              ),
              new Divider(
                color: Colors.blue,
              ),

              ElevatedButton(
                onPressed: _launchUrl2,
                child: Text('Contact Us'),
              ),
              new Divider(
                color: Colors.blue,
              ),
              SizedBox(height: 50,),
              new Divider(
                color: Colors.blue,
              ),

            ]),
      ),
    ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),

    );
  }
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
  Future<void> _launchUrl2() async {
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $_url');
    }
  }
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'jayaaliwithanage@gmail.com',

  );

  @override
  void dispose() {
    super.dispose();

  }
}




