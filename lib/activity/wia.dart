import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class WiaPage extends StatefulWidget {
  int id;
  WiaPage({Key? key, required this.id}) : super(key: key);

  @override
  _WiaPageState createState() => _WiaPageState();
}

class _WiaPageState extends State<WiaPage> {
  final controller = ScrollController();

  List items = [];

  int page = 1;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetch();

    // controller.addListener(() {
    //   if (controller.position.maxScrollExtent == controller.offset) {
    //     fetch();
    //   }
    // });
  }

  Future fetch() async {
    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/daily-wia/" +
            widget.id.toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      setState(() {
        data.forEach((value) {
          final _tile = {};
          _tile['id'] = value['id'];
          _tile['content'] = value['content'];
          _tile['checked'] = (value['checked'] == "1") ? true : false;
          items.add(_tile);
          // items[]
        });
        isLoading = false;
      });
    }
  }

  save_daily() async {
    final id = widget.id;

    String _items = jsonEncode(items).toString();

    print(_items);

    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/save-daily");

    setState(() {
      isLoading = true;
      items.clear();
    });

    try {
      final response =
          await http.post(url, body: {"id": id.toString(), "data": _items});

      final datauser = json.decode(response.body);

      if (datauser['success']) {
        final _data = datauser['data'];
        setState(() {
          fetch();
        });
      }
    } on Exception catch (e) {
      print("error caught : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "World Influencing Action",
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(
                CupertinoIcons.arrow_left,
                color: Colors.white,
              )),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index < items.length) {
                  final item = items[index];

                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 10)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.white,
                        border: Border.all(
                            style: BorderStyle.solid, color: Colors.white)),
                    margin: EdgeInsets.all(10),
                    child: Container(
                      child: ListTile(
                        leading: Container(
                            child: Checkbox(
                          value: items[index]['checked'],
                          onChanged: (bool? value) {
                            setState(() {
                              item['checked'] = true;
                            });
                          },
                        )),
                        title: Text(item['content']),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(""),
                    ),
                  );
                }
              }),
        ],
      )),
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.deepPurpleAccent,
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () async {
          save_daily();
        },
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
