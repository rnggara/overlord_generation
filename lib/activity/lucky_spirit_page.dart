import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class LuckySpiritPage extends StatefulWidget {
  final int id;
  const LuckySpiritPage({Key? key, required this.id}) : super(key: key);

  @override
  _LuckySpiritPageState createState() => _LuckySpiritPageState();
}

class _LuckySpiritPageState extends State<LuckySpiritPage> {
  bool isLoading = false;
  TextEditingController post = new TextEditingController();
  String userImg = "";
  bool isError = false;

  Future fetch() async {
    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/get-image/" +
            widget.id.toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      setState(() {
        userImg = data;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetch();
    super.initState();
  }

  _showAlert(title, text) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('OK'),
                )
              ],
            ));
  }

  Future _post() async {
    final id = widget.id;

    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/generate-image");

    setState(() {
      userImg = "";
      isLoading = true;
    });

    try {
      final response = await http.post(url, body: {"id": id.toString()});

      final datauser = json.decode(response.body);

      if (datauser['success']) {
        final _data = datauser['data'];
        setState(() {
          isLoading = false;
          isError = false;
          userImg = _data;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
          _showAlert("Generate Image Failed", datauser['message']);
        });
      }
    } on Exception catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "Lucky Spirit",
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
      body: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: const CircularProgressIndicator()))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white,
                      border: Border.all(
                          style: BorderStyle.solid, color: Colors.white)),
                  child: userImg != ""
                      ? ClipRect(
                          child: Material(
                            color: Colors.deepPurple[300],
                            child: Image.network(
                              userImg,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : ClipRect(
                          child: Material(
                            color: Colors.deepPurple[300],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.image,
                                size: 200,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
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
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text("Generate Image"),
                    content: Text("Need 100 Karma point for generate"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _post();
                          Navigator.pop(context, 'Yes');
                          if (isError) {
                            // _showAlert("Generate Image Failed", "heho");
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ));
        },
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            'Generate',
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
