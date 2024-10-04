import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfile createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();

  @override
  void initState() {
    gettingData();
    super.initState();
  }

  // Getting Data
  Future gettingData() async {
    var result = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get();
    _nameTextEditingController.text = result.data()!['fullName'];
    _emailTextEditingController.text = result.data()!['email'];
    _addressTextEditingController.text = result.data()!['address'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "تعديل البيانات",
                              style: TextStyle(
                                  color: CustomColors.PrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  fontSize: 25),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: _nameTextEditingController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "Full Name",
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: CustomColors.PrimaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: _emailTextEditingController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Email",
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: _addressTextEditingController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "Address",
                                  prefixIcon: const Icon(
                                    Icons.location_on,
                                    color: CustomColors.PrimaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            updateData();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              CustomColors.PrimaryColor,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              "تحديث البيانات",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  updateData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    updatingData();
  }

  Future updatingData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .update({
      "email": _emailTextEditingController.text.trim(),
      "fullName": _nameTextEditingController.text.trim(),
      "address": _addressTextEditingController.text.trim(),
    }).then((value) {
      Navigator.pop(context); // Close the progress dialog
    });
  }
}
