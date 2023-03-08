import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlord_generation/activitiy/arena.dart';
import 'package:overlord_generation/activitiy/bag.dart';
import 'package:overlord_generation/activitiy/market.dart';
import 'package:overlord_generation/activitiy/practice.dart';
import 'package:overlord_generation/activitiy/town.dart';
import 'package:overlord_generation/models/profile.dart';
import 'package:overlord_generation/res/customColors.dart';
import 'package:overlord_generation/res/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  final SharedPreferences pref;
  const UserScreen({Key? key, required this.pref}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _state = true;

  Profile? profile;
  Map<dynamic, dynamic> _char = {};
  Map<dynamic, dynamic> _user = {};
  List<dynamic> _items = [];

  String? gold, age;

  bool loading = true;

  var content;

  void townContent() async {
    widget.pref.reload();
    _char = await json.decode(widget.pref.getString('charData').toString())[0];
    _user = await json.decode(widget.pref.getString('userData').toString());
    _items = await json.decode(widget.pref.getString('itemsData').toString());
    setState(() {
      loading = false;
      content = TownScreen(
        user: _user,
        char: _char,
        market: () {
          setState(() {
            content = MarketScreen(
              user: _user,
              char: _char,
              callback: initProfile,
            );
          });
        },
        arena: () {
          setState(() {
            content = ArenaScreen(
              user: _user,
              char: _char,
              callback: initProfile,
            );
          });
        },
        practice: () {
          setState(() {
            content = PracticeScreen(user: _user, char: _char);
          });
        },
      );
      initProfile();
    });
  }

  Future initProfile() async {
    print("init profile");
    widget.pref.reload();
    _char = await json.decode(widget.pref.getString('charData').toString())[0];
    _user = await json.decode(widget.pref.getString('userData').toString());
    setState(() {
      gold = _user['do_code'].toString();
      age = _char['t_age_current'].toString();
    });
  }

  @override
  void initState() {
    _char = json.decode(widget.pref.getString('charData').toString())[0];
    _user = json.decode(widget.pref.getString('userData').toString());
    _items = json.decode(widget.pref.getString('itemsData').toString());
    townContent();
    initProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg/town.png'),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 40,
            elevation: 0,
            backgroundColor: Palette.themeYellow,
            leading: GestureDetector(
              onTap: () async {
                await widget.pref.reload();
                setState(() {
                  townContent();
                });
              },
              child: Icon(CupertinoIcons.home),
            ),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Expanded(
                child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  height: MediaQuery.of(context).size.height * .19,
                  decoration: BoxDecoration(color: Palette.themeYellow),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Material(
                          child: Image.asset(
                            _char['bank_acct'].toString(),
                            height: 100,
                          ),
                        ),
                      ),
                      Text(
                        _char['name']
                            .toString()
                            .toUpperCase()
                            .replaceAll(" ", "\n"),
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: fontLg,
                            color: Colors.white),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16),
                        width: MediaQuery.of(context).size.width * .25,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons/goldcoin.png',
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("$gold",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: fontSm,
                                        color: Colors.white))
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons/timer.png',
                                  height: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text((age ?? "1") + " yo",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: fontSm,
                                        color: Colors.white))
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await widget.pref.reload();
                                Map newChar = await json.decode(widget.pref
                                    .getString('charData')
                                    .toString())[0];
                                List newItems = await json.decode(widget.pref
                                    .getString('itemsData')
                                    .toString());
                                setState(() {
                                  content = BagScreen(
                                    user: _user,
                                    char: newChar,
                                    items: newItems,
                                  );
                                });
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/icons/bagpack.png',
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Bag",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: fontSm,
                                          color: Colors.white))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading
                    ? SpinKitFadingCircle(
                        color: Colors.white,
                      )
                    : content
              ],
            )),
          ),
        ));
  }
}
