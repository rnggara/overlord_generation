import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_weather/layout/AppBarBuilder.dart';
import 'package:http/http.dart' as http;

class InfinityScroll extends StatefulWidget {
  const InfinityScroll({Key? key}) : super(key: key);

  @override
  State<InfinityScroll> createState() => _InfinityScrollState();
}

class _InfinityScrollState extends State<InfinityScroll> {
  final controller = ScrollController();

  List<String> items = [];

  int page = 1;
  bool hasMore = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetch();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    const limit = 25;
    final url = Uri.parse(
        "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List newItems = jsonDecode(response.body);

      setState(() {
        page++;

        if (newItems.length < limit) {
          hasMore = false;
        }

        items.addAll(newItems.map<String>((item) {
          final number = item['id'];

          return 'Item $number';
        }).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(title: "Infinity Scrolls"),
      body: ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(10),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              final item = items[index];

              return ListTile(title: Text(item));
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: hasMore
                      ? const CircularProgressIndicator()
                      : const Text("No more data to load"),
                ),
              );
            }
          }),
    );
  }
}
