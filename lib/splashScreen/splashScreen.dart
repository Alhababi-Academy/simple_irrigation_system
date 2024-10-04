import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_irrigation_system/authentication/loginPage.dart';
import 'package:simple_irrigation_system/home/homePage.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  // when page open, this is the frist thing to do
  void initState() {
    // custom Function
    timeFunctoni();
    super.initState();
  }

  timeFunctoni() {
    // this will take 4 seconds
    Timer(
      const Duration(seconds: 4),
      () async {
        if (FirebaseAuth.instance.currentUser != null) {
          // Go to home page, because user is logged in
          Route route = MaterialPageRoute(builder: (_) => const HomePage());
          Navigator.pushAndRemoveUntil(context, route, (route) => false);
        } else {
          // got to login page because user is not logged in
          Route route = MaterialPageRoute(builder: (_) => const LoginPage());
          Navigator.pushAndRemoveUntil(context, route, (route) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "مرحبا",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: CustomColors.PrimaryColor,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            CircularProgressIndicator(
              color: CustomColors.PrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
