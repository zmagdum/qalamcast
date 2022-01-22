import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podcast_app/screens/dashboard/dashboard.dart';
import 'package:podcast_app/utility/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(Images.SplashBG, fit: BoxFit.cover, width: double.infinity),
        Image.asset(Images.logo)
      ],
    );
  }
}
