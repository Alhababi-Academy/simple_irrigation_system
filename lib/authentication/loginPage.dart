import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore package for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing FirebaseAuth package for user authentication
import 'package:flutter/material.dart'; // Importing the Flutter material package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_irrigation_system/DialogBox/errorDialog.dart';
import 'package:simple_irrigation_system/DialogBox/loadingDialog.dart';
import 'package:simple_irrigation_system/authentication/registerPage.dart';
import 'package:simple_irrigation_system/authentication/resetPassword.dart';
import 'package:simple_irrigation_system/home/homePage.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart'; // Importing shared preferences package for storing data

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "تسجيل دخول",
                  style: TextStyle(
                    color: CustomColors.PrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "الايميل",
                    prefixIcon: const Icon(Icons.email,
                        color: CustomColors.PrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordTextEditingController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "الرمز",
                    prefixIcon: const Icon(Icons.lock,
                        color: CustomColors.PrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  checkingData();
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(CustomColors.PrimaryColor),
                ),
                child: const Text(
                  "تسجيل دخول",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (_) => const RegisterPage());
                      Navigator.push(context, route);
                    },
                    child: const Text(
                      "لا تملك حساب؟ سجل الان",
                      style: TextStyle(
                        color: CustomColors.PrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Route route =
                          MaterialPageRoute(builder: (_) => ResetPassword());
                      Navigator.push(context, route);
                    },
                    child: const Text(
                      "نسيت الرمز ؟",
                      style: TextStyle(
                        color: CustomColors.PrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkingData() async {
    if (_emailTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text.isNotEmpty) {
      uploadToStorage();
    } else {
      displayDialog("يرجى ملء المعلومات");
    }
  }

  displayDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return ErrorAlertDialog(message: msg);
      },
    );
  }

  uploadToStorage() async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingAlertDialog(
          message: "المصادقة ، الرجاء الانتظار ...",
        );
      },
    );
    _login();
  }

  var currentUser;
  void _login() async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!.uid;
      saveUserInfo(currentUser);
    }).catchError(
      (error) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (c) => ErrorAlertDialog(message: error.toString()),
        );
      },
    );
  }

  saveUserInfo(String userAuth) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userAuth)
        .get()
        .then((result) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("emailShared", result.data()!['email']);
      sharedPreferences.setString("uid", currentUser.toString());
      sharedPreferences.setString("name", result.data()!['fullName']);
      Navigator.pop(context);
      Route route = MaterialPageRoute(builder: (context) => const HomePage());
      Navigator.pushAndRemoveUntil(context, route, (_) => false);
    });
  }
}
