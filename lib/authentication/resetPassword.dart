import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_irrigation_system/DialogBox/errorDialog.dart';
import 'package:simple_irrigation_system/DialogBox/loadingDialog.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart';

class ResetPassword extends StatelessWidget {
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        title: const Text(
          "استعادة الرمز",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "استعادة الرمز",
                      style: TextStyle(
                        color: CustomColors.PrimaryColor,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
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
                          prefixIcon: const Icon(
                            Icons.email,
                            color: CustomColors.PrimaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        checkIfEmailIsEmpty(context);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(CustomColors.PrimaryColor),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "استعادة",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkIfEmailIsEmpty(BuildContext context) {
    if (_emailTextEditingController.text.isNotEmpty) {
      resetPasswordFun(context);
    } else {
      showDialog(
        context: context,
        builder: (_) => const ErrorAlertDialog(message: "يرجى ملء المعلومات"),
      );
    }
  }

  resetPasswordFun(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LoadingAlertDialog(
        message: "جاري استعادة البيانات ، يرجاء الانتظار ...",
      ),
    );
    resetingPassword(context);
  }

  resetingPassword(BuildContext context) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailTextEditingController.text.trim())
        .then(
      (value) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => const ErrorAlertDialog(message: "تم ارسال الرمز"),
        );
      },
    ).catchError(
      (error) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) =>
              const ErrorAlertDialog(message: "فضلا تاكد من الايميل"),
        );
      },
    );
  }
}
