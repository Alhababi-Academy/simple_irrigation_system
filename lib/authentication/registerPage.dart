// Import necessary packages and files
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication package
import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:simple_irrigation_system/DialogBox/errorDialog.dart'; // Custom error dialog box
import 'package:simple_irrigation_system/DialogBox/loadingDialog.dart'; // Custom loading dialog box
import 'package:simple_irrigation_system/authentication/loginPage.dart'; // Login page
import 'package:simple_irrigation_system/widgets/Colord.dart'; // Custom colors
import 'package:shared_preferences/shared_preferences.dart'; // Shared preferences for local storage

// Define a class named RegisterPage that extends StatefulWidget
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Define the state class _RegisterPageState
class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameTextEditingController =
      TextEditingController(); // Controller for the name input field
  final TextEditingController _emailTextEditingController =
      TextEditingController(); // Controller for the email input field
  final TextEditingController _passwordTextEditingController =
      TextEditingController(); // Controller for the password input field
  final TextEditingController _addressTextEditingController =
      TextEditingController(); // Controller for the address input field

  @override
  Widget build(BuildContext context) {
    // Build the UI scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "انشاء حساب",
                          style: TextStyle(
                            color:
                                CustomColors.PrimaryColor, // Set the text color
                            fontSize: 24, // Set the font size
                            fontWeight: FontWeight.bold, // Set the font weight
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _nameTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "الاسم كامل",
                            prefixIcon: const Icon(Icons.person,
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _addressTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "العنوان",
                            prefixIcon: const Icon(Icons.location_on,
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
                          checkingDataRegister(); // Perform data validation and register account
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              CustomColors.PrimaryColor),
                        ),
                        child: const Text(
                          "انشاء حساب", // Set the button text
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Route route = MaterialPageRoute(
                              builder: (_) =>
                                  const LoginPage()); // Navigate to the login page
                          Navigator.push(context, route);
                        },
                        child: const Text(
                          "تملك حساب؟ سجل الدخول", // Set the text for the text button
                          style: TextStyle(color: CustomColors.PrimaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Perform data validation before registering an account
  Future<void> checkingDataRegister() async {
    if (_emailTextEditingController.text.isNotEmpty &&
        _nameTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text.isNotEmpty &&
        _addressTextEditingController.text.isNotEmpty) {
      registeringAccount();
    } else {
      displayDialog("يرجى ملء المعلومات");
    }
  }

  // Display an error dialog with the given message
  displayDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return ErrorAlertDialog(
          message: msg, // Set the error message to be displayed
        );
      },
    );
  }

  // Register the account with the provided data
  registeringAccount() async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingAlertDialog(
          message:
              "جاري حفظ البيانات ، يرجاء الانتظار ...", // Display a loading dialog while registering
        );
      },
    );
    _registering(); // Register the account
  }

  var currentUser; // Empty variable to hold current user ID
  void _registering() async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user?.uid;
      saveUserInfo(currentUser); // Save user info in the database
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) => ErrorAlertDialog(
          message: error.message
              .toString(), // Display an error dialog with the error message
        ),
      );
    });
  }

  // Save user information in the database
  Future saveUserInfo(String? currentUser) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUser).set({
      "uid": currentUser.toString(),
      "email": _emailTextEditingController.text.trim(),
      "fullName": _nameTextEditingController.text.trim(),
      "address": _addressTextEditingController.text.trim(),
      "RegistredTime": DateTime.now(),
    });
    Navigator.pop(context);
    Route route = MaterialPageRoute(builder: (context) => const LoginPage());
    Navigator.pushReplacement(context, route); // Navigate to the login page
  }
}
