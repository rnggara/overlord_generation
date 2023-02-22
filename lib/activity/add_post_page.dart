import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class PostPage extends StatefulWidget {
  final int id;
  const PostPage({Key? key, required this.id}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isLoading = false;
  TextEditingController post = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future _post() async {
    final id = widget.id;

    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/post-daily");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .post(url, body: {"id": id.toString(), "post": post.text.toString()});

      final datauser = json.decode(response.body);

      if (datauser['success']) {
        final _data = datauser['data'];
        setState(() {
          isLoading = false;
          Navigator.pop(context, true);
        });
      } else {
        setState(() {
          isLoading = false;
          Navigator.pop(context, true);
        });
      }
    } on Exception catch (e) {
      print("error caught : $e");
      setState(() {
        isLoading = false;
        Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder(
          title: "Add Post",
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
            : Container(
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
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: TextField(
                        controller: post,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    style: BorderStyle.solid,
                                    color: Colors.black)),
                            hintText: "Write your thoughts here"),
                      ),
                    ),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
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
                            _post();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ));
  }
}
