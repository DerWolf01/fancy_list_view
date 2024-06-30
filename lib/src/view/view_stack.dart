import 'package:fancy_list_view/main.dart';
import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:flutter/material.dart';

class FancyListStack extends StatefulWidget {
  FancyListStack(
    this.view,
  );

  final FancyListView view;
  @override
  final GlobalKey<FancyListStackState> key = GlobalKey();
  @override
  State<StatefulWidget> createState() => FancyListStackState();
}

class FancyListStackState extends State<FancyListStack> {
  List<FancyListItem>? items;

  final GlobalKey<FancyListStackState> key = GlobalKey();
  @override
  void initState() {
    super.initState();

    items = widget.view.controller
        .onInit(widget.view, widget.key, widget.view.height);
    controller.createOnAddListener(
      (value) async {
        print("new item: $value: {height: ${value?.height}, y: ${value?.y}}");
        if (value == null) {
          return;
        }
        setState(() {
          items = controller.items;
        });
      },
    );

    controller.createOnRemoveListener(
      (index) {
        items!.removeWhere(
          (element) => element.index == index,
        );
      },
    );
  }

  FancyListController get controller => widget.view.controller;
  @override
  Widget build(BuildContext context) {
    return Stack(children: items!);
  }
}
