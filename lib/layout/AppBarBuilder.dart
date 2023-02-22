import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarBuilder extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? icons;
  final Widget? leading;
  final List<Widget>? bottom;
  const AppBarBuilder(
      {Key? key, this.title, this.icons, this.leading, this.bottom})
      : super(key: key);

  @override
  _AppBarBuilderState createState() => _AppBarBuilderState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _AppBarBuilderState extends State<AppBarBuilder> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.leading == null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.arrow_left,
                    color: Colors.white,
                  )),
            )
          : widget.leading,
      leadingWidth: 50,
      toolbarHeight: 50,
      // centerTitle: true,
      title: new TextButton(
          onPressed: () {
            print("ini " + widget.title.toString());
          },
          child: Text(widget.title.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16))),
      actions: widget.icons,
      // bottom: widget.bottom,
    );
  }
}
