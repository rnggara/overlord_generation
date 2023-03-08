import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlord_generation/res/customColors.dart';
import 'package:http/http.dart' as http;
import 'package:overlord_generation/res/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArenaScreen extends StatefulWidget implements PreferredSizeWidget {
  final Map user;
  final Map char;
  final VoidCallback callback;
  const ArenaScreen(
      {Key? key,
      required this.user,
      required this.char,
      required this.callback})
      : super(key: key);

  @override
  _ArenaScreenState createState() => _ArenaScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _ArenaScreenState extends State<ArenaScreen> {
  final controller = ScrollController();

  Map<dynamic, dynamic> _user = {};

  bool isPVP = false;
  bool isPVPDone = false;
  bool isAble = true;

  bool loadState = false;
  bool isWin = false;

  String msgResult = "";

  int entry = 10;

  Future getArenaResult() async {
    final uri = Uri.parse("$baseUri/og/arena-result");

    final _post = {
      "id": _user['id'].toString(),
      "char": widget.char['id'].toString(),
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "Sorry, you lost the duel. Claim back your entry fee (10g)";
      if (data['success']) {
        if (data['data']) {
          msg = "Congratulation, you won the duel. Claim your prize (20g)";
          setState(() {
            isWin = true;
          });
        }
      } else {
        print(data['message']);
      }

      setState(() {
        loadState = false;
        msgResult = msg;
      });
    } catch (e) {}
  }

  Future claimArena() async {
    final uri = Uri.parse("$baseUri/og/claim-arena");

    final _post = {"id": _user['id'].toString(), "win": isWin.toString()};

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);
      print(data);
      if (data['success']) {
        final _data = data['data'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('userData', json.encode(_data).toString());
        await pref.reload();
        widget.callback();
        setState(() {
          _user = _data;
        });
      } else {
        print(data['message']);
      }
    } catch (e) {
      print("error log : ${e.toString()}");
    }
    setState(() {
      checkStatus(_user);
      loadState = false;
    });
  }

  Future enterArena() async {
    final uri = Uri.parse("$baseUri/og/join-arena");

    setState(() {
      // loading = true;
    });

    final _post = {
      "id": _user['id'].toString(),
      "char": widget.char['id'].toString(),
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "";
      if (data['success']) {
        final _data = data['data'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('userData', json.encode(_data).toString());
        await pref.reload();
        widget.callback();
      } else {
        print(data['message']);
      }

      setState(() {
        isPVP = true;
      });

      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text("Success"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  )
                ],
              ));
    } catch (e) {
      setState(() {
        // loading = false;
        // errorMsg = "msg";
      });
      print("No Internet Connection 😱 $e");
    }
  }

  checkStatus(p1) {
    if (p1['attend_code'] != null && p1['attend_code'] >= 1) {
      isPVP = true;
      if (p1['attend_code'] == 2) {
        isPVPDone = true;
      }
    } else {
      isPVP = false;
      isPVPDone = false;
    }

    try {
      if (int.parse(p1['do_code']) < entry) {
        isAble = false;
      } else {
        isAble = true;
      }
    } catch (e) {
      if (p1['do_code'] < entry) {
        isAble = false;
      } else {
        isAble = true;
      }
    }
  }

  @override
  void initState() {
    _user = widget.user;
    checkStatus(_user);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.char['name'].toString().toUpperCase();

    var _about =
        "Entry fee is 10g, and if you win you can get double the entry fee.\n\nBut if you lost, you get the entry fee back.\n\nEvery entry of the arena will increase your character’s age by 1 month.\n\nYou will be matched with players in your rank. You’re rank will be decided by how old your character is.";
    _about += "\n\nRank 5: 18 – 30 yo";
    _about += "\nRank 4: 31 – 40 yo";
    _about += "\nRank 3: 41 – 55 yo";
    _about += "\nRank 2: 56 – 70 yo";
    _about += "\nRank 1: 71 – 100 yo";

    var _entry = "Please hand out 10g to register your match.";
    _entry +=
        "\n\nAfter confirming, we will wait for other players to fight you.";
    _entry +=
        "\nPlease remember that you must wait for this fight to finish before you can do activities that increase age.";

    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 16),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .07,
                  color: Colors.white54,
                  alignment: Alignment.center,
                  child: Text(
                    "Arena",
                    style: TextStyle(
                        color: Palette.themePrimary,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white54),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Welcome to Arena.\n$name is in Rank 5 with 100 other\nplayers.",
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Palette.themePrimary,
                                  minimumSize: const Size.fromHeight(30)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: Text("Sure!"),
                                          content: Flexible(
                                              child: Text(
                                            _about,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "Montserrat"),
                                          )),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, "OK"),
                                                child: Text("OK"))
                                          ],
                                        ));
                              },
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                    'Explain about the arena',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: "Montserrat"),
                                  )),
                            )),
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: isPVP
                                      ? isPVPDone
                                          ? Palette.themeOrange
                                          : Palette.themeYellow
                                      : Palette.themePrimary,
                                  minimumSize: const Size.fromHeight(30)),
                              onPressed: isPVP
                                  ? !isPVPDone
                                      ? () {}
                                      : loadState
                                          ? null
                                          : () async {
                                              setState(() {
                                                loadState = true;
                                              });
                                              await getArenaResult();
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
                                                      AlertDialog(
                                                        title: Text(
                                                            "Arena Result"),
                                                        content: loadState
                                                            ? SpinKitFadingCircle(
                                                                color: Colors
                                                                    .black38,
                                                              )
                                                            : Flexible(
                                                                child: Text(
                                                                    "$msgResult",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            "Montserrat"))),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                claimArena();
                                                                Navigator.pop(
                                                                    context,
                                                                    "Claim");
                                                              },
                                                              child:
                                                                  Text("Claim"))
                                                        ],
                                                      ));
                                            }
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: Text(""),
                                                content: Flexible(
                                                    child: Text(
                                                  _entry,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: "Montserrat"),
                                                )),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context,
                                                              "Cancel"),
                                                      child: Text("Cancel")),
                                                  isAble
                                                      ? TextButton(
                                                          onPressed: () {
                                                            enterArena();
                                                            Navigator.pop(
                                                                context, "OK");
                                                          },
                                                          child: Text("OK"))
                                                      : Container()
                                                ],
                                              ));
                                    },
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                    isPVP
                                        ? isPVPDone
                                            ? "See the result!"
                                            : "Waiting for challenger"
                                        : "I would like to enter the arena",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: "Montserrat"),
                                  )),
                            ))
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
