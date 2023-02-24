import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlord_generation/activitiy/user_screen.dart';
import 'package:overlord_generation/res/customColors.dart';

class TownScreen extends StatefulWidget implements PreferredSizeWidget {
  final Map user;
  final Map char;
  final Function()? market, arena;
  const TownScreen(
      {Key? key,
      required this.user,
      required this.char,
      required this.market,
      required this.arena})
      : super(key: key);

  @override
  _TownScreenState createState() => _TownScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _TownScreenState extends State<TownScreen> {
  bool isPVP = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.user['attend_code'] != null &&
        int.parse(widget.user['attend_code'].toString()) >= 1) {
      isPVP = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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
                    "Town",
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white54,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: GestureDetector(
                                  onTap: widget.market,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Palette.themeYellow,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 16,
                                        bottom: 16),
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Market",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat"),
                                        ),
                                        Text(
                                          "Buy anything\nyou need here",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat"),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: isPVP
                                            ? Colors.grey
                                            : Palette.themeOrange,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 16,
                                        bottom: 16),
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Dungeon",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat"),
                                        ),
                                        Text(
                                          "Venture into\nthe dungeons\n( +1 year )",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat"),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      IntrinsicHeight(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                                onTap: widget.arena,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Palette.themePrimary,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 16, bottom: 16),
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Arena",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Montserrat"),
                                      ),
                                      Text(
                                        "Challenge other\nplayers around the\nworld",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Montserrat"),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isPVP
                                          ? Colors.grey
                                          : Palette.themeGreen,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 16, bottom: 16),
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Practice",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Montserrat"),
                                      ),
                                      Text(
                                        "Focus on training\none of attribute\n( +1 year )",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Montserrat"),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            "Your Attributes",
                            style: TextStyle(
                                fontFamily: "Montserrat", fontSize: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/intelligence.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "INT : " +
                                              widget.char['t_int'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/strength.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "STR : " +
                                              widget.char['t_str'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/vitality.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "VIT : " +
                                              widget.char['t_hp'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/dexterity.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "DEX : " +
                                              widget.char['t_dex'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/agility.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "AGI : " +
                                              widget.char['t_agi'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/icons/luck.png",
                                          height: 25,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "LUK : " +
                                              widget.char['t_def'].toString(),
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 16),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
