import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:overlord_generation/activitiy/bag.dart';
import 'package:overlord_generation/activitiy/market.dart';
import 'package:overlord_generation/activitiy/town.dart';
import 'package:overlord_generation/models/profile.dart';
import 'package:overlord_generation/res/customColors.dart';
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

  var content;

  var _town;

  void changeContent(Material material) async {
    setState(() {
      content = material;
    });
  }

  @override
  void initState() {
    _char = json.decode(widget.pref.getString('charData').toString())[0];
    _user = json.decode(widget.pref.getString('userData').toString());
    _items = json.decode(widget.pref.getString('itemsData').toString());
    content = TownScreen(
      user: _user,
      char: _char,
      market: () {
        setState(() {
          content = MarketScreen(user: _user, char: _char);
        });
      },
    );

    _town = content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg/town.png'),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Palette.themeYellow,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  height: MediaQuery.of(context).size.height * .16,
                  decoration: BoxDecoration(color: Palette.themeYellow),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await widget.pref.reload();
                          setState(() {
                            content = _town;
                          });
                        },
                        child: ClipRect(
                          child: Material(
                            child: Image.asset(
                              _char['bank_acct'].toString(),
                              height: 100,
                            ),
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
                            fontSize: 16,
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
                                Text(_user['do_code'] ?? "0",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 16,
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
                                Text((_char['t_age_current'] ?? "1") + " yo",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 16,
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
                                setState(() {
                                  content = BagScreen(
                                    user: _user,
                                    char: newChar,
                                    items: _items,
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
                                          fontSize: 16,
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
                content
              ],
            ),
          ),
        ));
  }
}
