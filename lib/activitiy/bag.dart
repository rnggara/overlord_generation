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

  List<dynamic> itemList = [];

  String? weaponImg = "";
  String? armorimg = "";

  Future unequipItem(slot) async {
    final uri = Uri.parse("$baseUri/og/unequip-item");

    setState(() {
      // loading = true;
    });

    final _post = {
      "char": widget.char['id'].toString(),
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
        print("unequip");
        await pref.reload();
      } else {
        print(data['message']);
      }

      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text("Unequiped"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await setEquip();
                      Navigator.pop(context, 'OK');
                    },
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
        setEquip();
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

  itemEquip(el, slot) {
    var _title = slot == 1 ? "Weapons" : "Armors";
    final itemSplit = el['pre_num'].toString().split("/");
    final nameSplit = itemSplit[itemSplit.length - 1].toString().split(".");
    final name = nameSplit[0];

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Equip $_title"),
              content: Text("Equip $name"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        if (slot == 1) {
                          weaponImg = el['pre_num'].toString();
                        } else {
                          armorimg = el['pre_num'].toString();
                        }
                        equipItem(el['id'], slot);
                      });
                      Navigator.pop(context, 'YES');
                    },
                    child: Text("Yes"))
              ],
            ));
  }

  setEquip() async {
    itemList.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var char = await json.decode(pref.getString('charData').toString())[0];
    weaponImg = "";
    armorimg = "";
    for (var i = 0; i < widget.items.length; i++) {
      var el = widget.items[i];
      if (el['id'].toString() == char['luck_1'].toString()) {
        setState(() {
          weaponImg = el['pre_num'];
        });
      } else if (el['id'].toString() == char['luck_2'].toString()) {
        setState(() {
          armorimg = el['pre_num'];
        });
      } else {
        print(el['id']);
        setState(() {
          itemList.add(el);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getDir();

    setEquip();
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white54,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Bag",
                    style: TextStyle(
                        color: Palette.themePrimary,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: fontXl),
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
                                    Container(
                                      child: weaponImg == ""
                                          ? Container()
                                          : Container(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                  "Unequip Weapon"),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'Cancel'),
                                                                    child: Text(
                                                                        "Cancel")),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        weaponImg =
                                                                            "";
                                                                      });
                                                                      unequipItem(
                                                                          1);
                                                                      Navigator.pop(
                                                                          context,
                                                                          'YES');
                                                                    },
                                                                    child: Text(
                                                                        "Yes"))
                                                              ],
                                                            ));
                                                  },
                                                  child: Image.asset(
                                                    weaponImg.toString(),
                                                    height: 70,
                                                  )),
                                            ),
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
                                    Container(
                                      child: armorimg == ""
                                          ? Container()
                                          : Container(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                  "Unequip Armor"),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'Cancel'),
                                                                    child: Text(
                                                                        "Cancel")),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        armorimg =
                                                                            "";
                                                                      });
                                                                      unequipItem(
                                                                          2);
                                                                      Navigator.pop(
                                                                          context,
                                                                          'YES');
                                                                    },
                                                                    child: Text(
                                                                        "Yes"))
                                                              ],
                                                            ));
                                                  },
                                                  child: Image.asset(
                                                    armorimg.toString(),
                                                    height: 70,
                                                  )),
                                            ),
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
                                        itemCount: itemList.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 1.3,
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 10),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final el = itemList[index];
                                          return GestureDetector(
                                              onTap: () {
                                                itemEquip(el, el['pre_id']);
                                              },
                                              child: Container(
                                                child: Image.asset(
                                                  el['pre_num'],
                                                  height: 20,
                                                ),
                                              ));
                                        },
                                      ))))
                        ],
                      )),
                ),
              ],
            )));
  }
}
