import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_irrigation_system/splashScreen/splashScreen.dart';
import 'package:simple_irrigation_system/widgets/sharedPrefrences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance;
  FirebaseAuth.instance;
  FirebaseDatabase.instance;

  configFile.sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, // Plant green color theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          elevation: 0,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.green,
        ),
      ),
      home: const splashScreen(),
    );
  }
}
