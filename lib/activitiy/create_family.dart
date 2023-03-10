import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlord_generation/activitiy/create_char.dart';
import 'package:overlord_generation/models/profile.dart';
import 'package:overlord_generation/res/values.dart';
import 'package:overlord_generation/utils/authentication.dart';
import 'package:overlord_generation/utils/profileUpdate.dart';
import 'package:overlord_generation/widgets/googleButton.dart';
import 'package:http/http.dart' as http;

class CreateFamily extends StatefulWidget {
  final User _user;
  const CreateFamily({Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _CreateFamilyState createState() => _CreateFamilyState();
}

class _CreateFamilyState extends State<CreateFamily> {
  TextEditingController _familyName = new TextEditingController();

  bool loading = false;
  String errorMsg = "";

  Future _post() async {
    var _token = await FirebaseMessaging.instance.getToken();
    var email = widget._user.email;

    final uri = Uri.parse("$baseUri/og/check-family-name");

    setState(() {
      loading = true;
    });

    final _post = {
      "name": _familyName.text.toString(),
      "email": email,
      "device_id": _token
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "";
      if (data['success']) {
        msg = data['message'];
      } else {
        msg = data['message'];
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CreateChar(user: widget._user),
        ),
      );

      setState(() {
        loading = false;
        errorMsg = msg;
      });
    } on SocketException {
      setState(() {
        loading = false;
        errorMsg = "msg";
      });
      print("No Internet Connection ????");
    } on HttpException {
      setState(() {
        loading = false;
        errorMsg = "msg";
      });
      print("Couldn't find the post ????");
    } on FormatException {
      setState(() {
        loading = false;
        errorMsg = "msg";
      });
      print("Bad response format ????");
    }
  }

  @override
  void initState() {
    super.initState();
    // profile.then((String value) {
    //   print(value);
    // });
  }

  @override
  Widget build(BuildContext context) {
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
              body: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 10)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.white,
                        border: Border.all(
                            style: BorderStyle.solid, color: Colors.white)),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                        ),
                        Text(
                          "Please enter your family name",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: TextField(
                            controller: _familyName,
                            decoration: new InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1,
                                        style: BorderStyle.solid,
                                        color: Colors.black))),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          errorMsg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                minimumSize: const Size.fromHeight(50)),
                            onPressed: loading
                                ? null
                                : () async {
                                    // _post();
                                    setState(() {
                                      _post();
                                    });
                                  },
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: loading
                                  ? SpinKitRing(
                                      color: Colors.white,
                                      size: 40,
                                    )
                                  : Text(
                                      'SUBMIT',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                        )
                      ],
                    )),
              )),
        ));
  }
}
