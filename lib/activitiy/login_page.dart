import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:overlord_generation/models/profile.dart';
import 'package:overlord_generation/utils/authentication.dart';
import 'package:overlord_generation/utils/profileUpdate.dart';
import 'package:overlord_generation/widgets/googleButton.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _state = true;

  ProfileUpdate _profileUpdate = new ProfileUpdate();

  Profile? profile;

  Future getProfile() async {
    profile = await _profileUpdate.getProfile();
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    // profile.then((String value) {
    //   print(value);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg/login.png'),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  "Overlord Generation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat"),
                )),
            floatingActionButton: FutureBuilder(
              future: Authentication.initializeFirebase(context: context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error initializing Firebase');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return GoogleSignInButton();
                }
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ));
  }
}
