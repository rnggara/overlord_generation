import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlord_generation/activitiy/user_screen.dart';
import 'package:overlord_generation/models/profile.dart';
import 'package:overlord_generation/res/values.dart';
import 'package:overlord_generation/utils/authentication.dart';
import 'package:overlord_generation/utils/profileUpdate.dart';
import 'package:overlord_generation/widgets/googleButton.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateChar extends StatefulWidget {
  final User _user;
  const CreateChar({Key? key, required User user})
      : _user = user,
        super(key: key);

  @override
  _CreateCharState createState() => _CreateCharState();
}

class _CreateCharState extends State<CreateChar> {
  TextEditingController first_name = new TextEditingController();
  String genderSel = "";
  String classSel = "";
  List<String> gender = <String>['Male', 'Female'];
  List<String> classes = <String>['Warrior', 'Mage', 'Thief'];

  String? char_img = "assets/images/characters/default.jpg";
  final scrollController = ScrollController();

  List<String?> imgSel = [];
  String? imgDir = "";

  bool loading = false;
  bool state = false;
  String errorMsg = "";

  List<FileSystemEntity> _folders = [];
  getDir(dir) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/characters/$dir'))
        // .where((String key) => key.contains('.svg'))
        .toList();

    setState(() {
      imgSel = imagePaths;
    });

    // setState(() {
    //   someImages = imagePaths;
    // });
  }

  Future _post() async {
    var email = widget._user.email;

    final uri = Uri.parse("$baseUri/og/create-char");

    setState(() {
      loading = true;
    });

    final _post = {
      "name": first_name.text.toString(),
      "email": email,
      "gender": genderSel,
      "class": classSel,
      "image": char_img
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "";
      if (data['success']) {
        final _data = data['data'];
        final _uData = _data['user'];
        final _char = _data['char'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('uId', _uData['id'].toString());
        pref.setString('email', email.toString());
        pref.setString('imageChar', char_img.toString());
        pref.setString('charId', _char['id'].toString());
        pref.setString('charData', json.encode(_char).toString());
        pref.setString('userData', json.encode(_uData).toString());
        pref.setString('itemsData', json.encode([]).toString());

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserScreen(
              pref: pref,
            ),
          ),
        );
      }

      setState(() {
        loading = false;
        // errorMsg = msg;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMsg = "msg";
      });
      print("No Internet Connection 😱 $e");
    }
  }

  @override
  void initState() {
    super.initState();
    imgDir = "males";
    genderSel = gender.first;
    classSel = classes.first;
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
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(10),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height,
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
                          Image.asset("assets/images/icons/curve-line.png"),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Create a character",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Montserrat"),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Enter first name \nfor this character",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Montserrat"),
                                  ),
                                  TextField(
                                    controller: first_name,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != "" &&
                                            char_img !=
                                                "assets/images/characters/default.jpg") {
                                          state = true;
                                        }
                                      });
                                    },
                                    decoration: new InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38,
                                              width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                style: BorderStyle.solid,
                                                color: Colors.black38))),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Text(
                                    "Select Gender",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Montserrat"),
                                  ),
                                  DropdownButtonFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                  style: BorderStyle.solid))),
                                      value: genderSel,
                                      items: gender
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          genderSel = value!;
                                          char_img =
                                              "assets/images/characters/default.jpg";
                                          if (char_img ==
                                              "assets/images/characters/default.jpg") {
                                            setState(() {
                                              state = false;
                                            });
                                          }
                                          if (value.toLowerCase() == "male") {
                                            imgDir = "males";
                                          } else {
                                            imgDir = "females";
                                          }
                                        });
                                      }),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Text(
                                    "Select class for this character",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Montserrat"),
                                  ),
                                  DropdownButtonFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                  style: BorderStyle.solid))),
                                      value: classSel,
                                      items: classes
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          classSel = value!;
                                        });
                                      }),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Select image\n(tap to change)",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: "Montserrat"),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          getDir(imgDir);
                                          print(imgSel);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    title: Text("Select Image"),
                                                    content: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8,
                                                      child: GridView.builder(
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisSpacing:
                                                                    5,
                                                                mainAxisSpacing:
                                                                    5,
                                                                crossAxisCount:
                                                                    2),
                                                        itemCount:
                                                            imgSel.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final item =
                                                              imgSel[index];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                char_img =
                                                                    '$item';
                                                                if (first_name
                                                                        .text !=
                                                                    "") {
                                                                  state = true;
                                                                }
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: ClipRect(
                                                                child: Material(
                                                                    child: Image
                                                                        .asset(
                                                              '$item',
                                                              width: 20,
                                                            ))),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ));
                                        },
                                        child: ClipRect(
                                          child: Material(
                                            child: Image.asset(
                                              char_img.toString(),
                                              width: 100,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
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
                                  : !state
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
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      )),
                ),
              )),
        ));
  }
}
