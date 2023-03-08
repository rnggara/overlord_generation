import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlord_generation/res/customColors.dart';
import 'package:http/http.dart' as http;
import 'package:overlord_generation/res/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketScreen extends StatefulWidget implements PreferredSizeWidget {
  final Map user;
  final Map char;
  final VoidCallback callback;
  const MarketScreen(
      {Key? key,
      required this.user,
      required this.char,
      required this.callback})
      : super(key: key);

  @override
  _MarketScreenState createState() => _MarketScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _MarketScreenState extends State<MarketScreen> {
  List<String?> weapons = [];
  final controller = ScrollController();

  String _dir = "Weapons";
  int _slot = 1;

  Future postBuy(itemcode, price, img_uri) async {
    var id = widget.user['id'];

    final uri = Uri.parse("$baseUri/og/buy-item");

    setState(() {
      // loading = true;
    });

    final _post = {
      "id": id.toString(),
      "item": itemcode,
      "price": price.toString(),
      'img_uri': img_uri.toString(),
      'slot': _slot.toString()
    };

    try {
      final response = await http.post(uri, body: _post);

      final data = json.decode(response.body);

      var msg = "";
      if (data['success']) {
        final _data = data['data'];
        final _uData = _data['user'];
        final _items = _data['items'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('userData', json.encode(_uData).toString());
        pref.setString('itemsData', json.encode(_items).toString());
        widget.callback();
      }

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

  Future buyItem(itemcode, price, uri) async {
    final user = widget.user;
    var balance = 0;
    try {
      balance = int.parse(user['do_code']);
    } catch (e) {
      balance = user['do_code'];
    }
    var buyState = true;
    if (balance < price) {
      buyState = false;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(
                "Buy Item",
                style: TextStyle(fontFamily: "Montserrat"),
              ),
              content: !buyState
                  ? Text("Insuficience Balance",
                      style: TextStyle(fontFamily: "Montserrat"))
                  : Text(
                      "Buy $itemcode for $price Gold?",
                      style: TextStyle(fontFamily: "Montserrat"),
                    ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                buyState
                    ? TextButton(
                        onPressed: () {
                          postBuy(itemcode, price, uri);
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('OK'),
                      )
                    : Text(""),
              ],
            ));
  }

  getDir() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/items/$_dir'))
        // .where((String key) => key.contains('.svg'))
        .toList();

    setState(() {
      weapons = imagePaths;
      if (_dir == "Others") {
        _slot = 2;
      } else {
        _slot = 1;
      }
    });

    // setState(() {
    //   someImages = imagePaths;
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    getDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    "Market",
                    style: TextStyle(
                        color: Palette.themePrimary,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: fontXl),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _dir = "Weapons";
                                      getDir();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: _dir == "Weapons"
                                            ? Palette.themePrimary
                                            : Palette.themeNavy,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "Weapons",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            color: Colors.white),
                                      ),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _dir = "Others";
                                      getDir();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: _dir == "Others"
                                            ? Palette.themePrimary
                                            : Palette.themeNavy,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "Armors",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            color: Colors.white),
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                  color: Colors.white54,
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              child: Scrollbar(
                                  child: ListView.builder(
                                controller: controller,
                                itemCount: weapons.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = weapons[index];
                                  final itemSplit = item.toString().split("/");
                                  final nameSplit =
                                      itemSplit[itemSplit.length - 1]
                                          .toString()
                                          .split(".");
                                  final name = nameSplit[0];
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: ListTile(
                                      leading: Image.asset(
                                        item.toString(),
                                        height: 50,
                                      ),
                                      title: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(name),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/icons/goldcoin.png',
                                                  height: 30,
                                                ),
                                                Text("5 g")
                                              ],
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary:
                                                      Palette.themePrimary),
                                              onPressed: () async {
                                                await buyItem(name, 5, item);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8.0, bottom: 8.0),
                                                child: Text(
                                                  'BUY',
                                                  style: TextStyle(
                                                    fontSize: fontLg,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: "Montserrat",
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ))))
                    ],
                  ),
                ),
              ],
            )));
  }
}
