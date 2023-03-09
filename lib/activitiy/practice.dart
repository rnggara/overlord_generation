import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlord_generation/activitiy/create_char.dart';
import 'package:overlord_generation/res/customColors.dart';
import 'package:http/http.dart' as http;
import 'package:overlord_generation/res/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeScreen extends StatefulWidget implements PreferredSizeWidget {
  final Map user;
  final Map char;
  final VoidCallback callback;
  const PracticeScreen(
      {Key? key,
      required this.user,
      required this.char,
      required this.callback})
      : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String? _selectedLocation; // Option 2

  void charDie() async {
    final User usr = FirebaseAuth.instance.currentUser!;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => CreateChar(user: usr),
    ));
  }

  // final Map char;
  void postData(String s) async {
    var iD = widget.char['id'].toString(),
        staT = s.toString(),
        uiD = widget.user['id'];
    // var result = _selectedLocation?? "";
    if (_selectedLocation?.isEmpty ?? true) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text("stat cannot be empty"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: const Text('OK'),
                  )
                ],
              ));
    } else {
      final _post = {
        "id_char": iD.toString(),
        "id_user": uiD.toString(),
        "practice_type": staT.toLowerCase(),
        "fee": "20",
        'point': _selectedLocation.toString()
      };
      final uri = Uri.parse("$baseUri/og/update-stats");
      try {
        final response = await http.post(uri, body: _post);

        final data = json.decode(response.body);

        var msg = "Success";
        var isDie = false;
        SharedPreferences pref = await SharedPreferences.getInstance();
        if (data['success']) {
          final _data = data['data'];
          final _uData = _data['user'];
          final _char = _data['char'];
          final _ageLimit = _data['ageLimit'];
          if (!_ageLimit) {
            isDie = true;
            msg = "Your character is die. Create new character again!";
          }
          pref.setString('userData', json.encode(_uData).toString());
          pref.setString('char_data', json.encode(_char).toString());
          // var newGold = _data['do_code'];
          widget.callback();
        }

        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text("$msg"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context, 'OK');
                        Navigator.pop(context, 'OK');
                        if (isDie) {
                          await pref.setString('char_data', "");
                          charDie();
                        }
                      },
                      child: const Text('OK'),
                    )
                  ],
                ));
      } catch (e) {
        print("No Internet Connection 😱 $e");
      }
    }
  }

  void sdsd(String s, BuildContext context) {
    List<String> _locations = ["1", "2", "3", "4"];
    // url untuk update status base on stat yang ini di naekin
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        // print("ok "+s);
        postData(s);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return SizedBox(
            height: 100,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Point"),
                  DropdownButton(
                    hint: const Text("Point To Practice"),
                    items: _locations.map((String newValue) {
                      return DropdownMenuItem(
                        value: newValue,
                        child: Text(newValue),
                      );
                    }).toList(),
                    value: _selectedLocation,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  )
                ],
              ),
            ]),
          );
        },
      ),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return alert;
          });
        });
  }

  Widget btn(String s, context) {
    // var widthBtn = MediaQuery.of(context).size.width;
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          //change width and height on your need width = 200 and height = 50
          minimumSize: const Size(5, 30),
        ),
        onPressed: () {
          sdsd(s, context);
        },
        child: const Text('UP'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .07,
            color: Colors.white54,
            alignment: Alignment.center,
            child: const Text(
              "Practice",
              style: TextStyle(
                  color: Palette.themePrimary,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .35,
            color: Colors.white54,
            alignment: Alignment.center,
            child: Center(
              child: Column(children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/intelligence.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "INT : ",
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('INT', context)
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/strength.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "STR : ",
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('STR', context)
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/vitality.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "VIT : ",
                          style:
                              TextStyle(fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('VIT', context)
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/dexterity.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "DEX : ",
                          style:
                              TextStyle(fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('DEX', context)
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/agility.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "AGI : ",
                          style:
                              TextStyle(fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('AGI', context)
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icons/luck.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "LUK : ",
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 16),
                        ),
                        btn('LUK', context)
                      ],
                    )
                  ],
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
