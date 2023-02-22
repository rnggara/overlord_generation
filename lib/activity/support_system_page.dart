import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:test_weather/activity/add_post_page.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class SSP extends StatefulWidget {
  int id;
  SSP({Key? key, required this.id}) : super(key: key);

  @override
  _SSPState createState() => _SSPState();
}

class _SSPState extends State<SSP> {
  final controller = ScrollController();
  bool canPost = true;

  List items = [];
  List _liked = [];

  int page = 1;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetch();
  }

  Future fetch() async {
    items.clear();
    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/my-group/" +
            widget.id.toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final groups = data['groups'];
      final liked = data['liked'];

      setState(() {
        if (liked != []) {
          liked.forEach((value) {
            _liked.add(value);
          });
        }
        canPost = data['canPost'];

        groups.forEach((value) {
          final _tile = {};
          final isMe = (value['id'] == widget.id) ? true : false;
          _tile['id'] = value['id'].toString();
          _tile['name'] = value['name'];
          _tile['user_img'] = value['user_img'];
          _tile['content'] = value['access'] ?? "";
          _tile['isMe'] = isMe;
          items.add(_tile);
          // items[]
        });
        isLoading = false;
      });
    }
  }

  Future<bool> _like(target) async {
    var _like = false;
    final id = widget.id;

    String _items = jsonEncode(items).toString();

    final url = Uri.parse(
        "http://kaliberindonesia.com/fortune/public/api/ft/post-like");
    try {
      final response =
          await http.post(url, body: {"id": id.toString(), "target": target});

      final datauser = json.decode(response.body);

      if (datauser['success']) {
        _like = true;
      }

      if (datauser['data'] == "sudah di like") {
        _like = true;
      }
      return _like;
    } on Exception catch (e) {
      return _like;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "My Support System",
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

                  final isMe = item['isMe'];

                  final isLiked = _liked.contains(item['id']) ? true : false;

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
                        leading: item['user_img'] != ""
                            ? ClipOval(
                                child: Material(
                                  color: Colors.deepPurple[300],
                                  child: Image.network(
                                    item['user_img'],
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: Material(
                                  color: Colors.deepPurple[300],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name']),
                            SizedBox(height: 16.0),
                            (item['content'] == "")
                                ? Text(
                                    "No post",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black38),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(10),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                            style: BorderStyle.solid,
                                            color: Colors.black38)),
                                    child: Text(item['content']),
                                  ),
                            (isMe)
                                ? Text("")
                                : (item['content'] == "")
                                    ? Text("")
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            LikeButton(
                                              isLiked: isLiked,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              circleColor: CircleColor(
                                                  start: Color(0xff00ddff),
                                                  end: Color(0xff0099cc)),
                                              bubblesColor: BubblesColor(
                                                dotPrimaryColor:
                                                    Color(0xff33b5e5),
                                                dotSecondaryColor:
                                                    Color(0xff0099cc),
                                              ),
                                              onTap: (bool isLiked) async {
                                                return _like(item['id']);
                                              },
                                            ),
                                          ])
                          ],
                        ),
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
      floatingActionButton: !canPost
          ? null
          : ElevatedButton(
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
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => PostPage(
                          id: widget.id,
                        ),
                      ),
                    )
                    .then((value) => value ? fetch() : null);
              },
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Add Post',
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
