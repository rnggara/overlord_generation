import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class ReadingPage extends StatefulWidget {
  int id;
  ReadingPage({Key? key, required this.id}) : super(key: key);

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
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
        "http://kaliberindonesia.com/fortune/public/api/ft/reading/" +
            widget.id.toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      setState(() {
        data.forEach((key, value) {
          final _tile = {};
          _tile['id'] = value['id_metering'].toString();
          _tile['category'] = key.toString().toUpperCase();
          _tile['value'] = value['api_result'].replaceAll("\n\n", "");
          items.add(_tile);
          // items[]
        });
        isLoading = false;
      });
    }
  }

  reroll(metering_id) async {
    final id = widget.id;

    final url =
        Uri.parse("http://kaliberindonesia.com/fortune/public/api/ft/reroll");

    setState(() {
      isLoading = true;
      items.clear();
    });

    try {
      final response = await http.post(url,
          body: {"id": id.toString(), "id_metering": metering_id.toString()});

      final datauser = json.decode(response.body);

      if (datauser['success']) {
        final _data = datauser['data'];
        setState(() {
          fetch();
        });
      }

      print(response);
    } on Exception catch (e) {
      print("error caught : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "Reading",
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
      body: ListView.builder(
          controller: controller,
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
                    title: Row(children: [
                      Text(item['category']),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.orange,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text(
                                        "Re-roll " + item['category'] + "?"),
                                    content:
                                        Text("Need 100 Karma point to re-roll"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          print("re-roll");
                                          reroll(item['id']);
                                          Navigator.pop(context, 'Yes');
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                          child: Text(
                            'Re-roll',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ]),
                    subtitle: Text(item['value']),
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
    );
  }
}
