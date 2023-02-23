import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlord_generation/res/customColors.dart';
import 'package:http/http.dart' as http;
import 'package:overlord_generation/res/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BagScreen extends StatefulWidget implements PreferredSizeWidget {
  final Map user;
  final Map char;
  final List<dynamic> items;
  const BagScreen(
      {Key? key, required this.user, required this.char, required this.items})
      : super(key: key);

  @override
  _BagScreenState createState() => _BagScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _BagScreenState extends State<BagScreen> {
  List<String?> weapons = [];
  final controller = ScrollController();

  String? weaponImg = "";
  String? armorimg = "";

  Future equipItem(item, slot) async {
    final uri = Uri.parse("$baseUri/og/equip-item");

    setState(() {
      // loading = true;
    });

    final _post = {
      "char": widget.char['id'].toString(),
      "item": item.toString(),
      "slot": slot.toString()
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "";
      if (data['success']) {
        final _data = data['data'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('charData', json.encode(_data).toString());
        await pref.reload();
      } else {
        print(data['message']);
      }

      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text("Equiped"),
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

  getDir() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/items/Weapons'))
        // .where((String key) => key.contains('.svg'))
        .toList();

    setState(() {
      weapons = imagePaths;
    });

    // setState(() {
    //   someImages = imagePaths;
    // });
  }

  setEquip() {
    for (var i = 0; i < widget.items.length; i++) {
      var el = widget.items[i];
      print(el['id'].toString() + " = " + widget.char['luck_1'].toString());
      if (el['id'].toString() == widget.char['luck_1'].toString()) {
        setState(() {
          weaponImg = el['pre_num'];
        });
      }
      if (el['id'].toString() == widget.char['luck_2'].toString()) {
        setState(() {
          armorimg = el['pre_num'];
        });
      }
    }
    print(weaponImg);
  }

  @override
  void initState() {
    // TODO: implement initState
    getDir();

    setEquip();
    print(widget.char['luck_1']);
    print(weaponImg);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double itemHeight =
        (MediaQuery.of(context).size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = MediaQuery.of(context).size.width / 2;
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
                    "Bag",
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
                      color: Colors.white54,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                height: MediaQuery.of(context).size.width * .3,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Text(
                                      "Weapon",
                                      style:
                                          TextStyle(fontFamily: "Montserrat"),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    DragTarget(
                                      builder: (
                                        BuildContext context,
                                        List<dynamic> accepted,
                                        List<dynamic> rejected,
                                      ) {
                                        return Container(
                                          child: weaponImg == ""
                                              ? Container()
                                              : Container(
                                                  child: Image.asset(
                                                    weaponImg.toString(),
                                                    height: 70,
                                                  ),
                                                ),
                                        );
                                      },
                                      onAccept: (data) {
                                        setState(() {
                                          final el = widget.items[
                                              int.parse(data.toString())];
                                          weaponImg = el['pre_num'].toString();
                                          equipItem(el['id'], 1);
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                height: MediaQuery.of(context).size.width * .3,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Text(
                                      "Armor",
                                      style:
                                          TextStyle(fontFamily: "Montserrat"),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    DragTarget(
                                      builder: (
                                        BuildContext context,
                                        List<dynamic> accepted,
                                        List<dynamic> rejected,
                                      ) {
                                        return Container(
                                          child: armorimg == ""
                                              ? Container()
                                              : Container(
                                                  child: Image.asset(
                                                    armorimg.toString(),
                                                    height: 70,
                                                  ),
                                                ),
                                        );
                                      },
                                      onAccept: (data) {
                                        setState(() {
                                          final el = widget.items[
                                              int.parse(data.toString())];
                                          armorimg = el['pre_num'].toString();
                                          equipItem(el['id'], 2);
                                        });
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, top: 10),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: GridView.builder(
                                        itemCount: widget.items.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 1.3,
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 10),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final el = widget.items[index];
                                          final unequiped = weaponImg !=
                                                  el['pre_num'].toString()
                                              ? true
                                              : false;
                                          return unequiped
                                              ? Draggable(
                                                  data: index,
                                                  feedback: Container(
                                                    child: Image.asset(
                                                      el['pre_num'],
                                                      height: 80,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    child: Image.asset(
                                                      el['pre_num'],
                                                      height: 20,
                                                    ),
                                                  ),
                                                  childWhenDragging:
                                                      Container(),
                                                )
                                              : Container();
                                        },
                                      ))))
                        ],
                      )),
                ),
              ],
            )));
  }
}
