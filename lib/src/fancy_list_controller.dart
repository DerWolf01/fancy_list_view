import 'package:fancy_list_view/main.dart';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:flutter/material.dart';

class FancyListController {
  double listContentHeight = 0.0;
  late FancyListView view;
  List<FancyListItem> items = [];
  double changeY = 0.0;
  late final BuildContext context;
  void moveY(double y) {
    changeY += y;
    for (var item in items) {
      item.moveY(context, y);
      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }

  void endY() {
    for (var item in items) {
      item.moveYEnd(context);
      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }

  List<FancyListItem> onInit(
      BuildContext context, FancyListView view, bool dragging, double height) {
    listContentHeight = view.children.length * view.itemHeight;
    this.context = context;
    this.view = view;

    int index = 0;

    items = children.map((e) {
      var item = FancyListItem(
        isLastItem: index == view.children.length - 1,
        index: index,
        fancyListController: this,
        onEnter: AnimationStop(
          key: Key("onEnter"),
          x: (context) => 0.0,
          scale: (c, progress) => 1.0,
        ),
        onLeave: AnimationStop(
          key: Key("onLeave"),
          x: (context) => MediaQuery.sizeOf(context).width,
          scale: (c, progress) => 1.0,
        ),
        listHeight: height,
        height: itemHeight,
        key: Key(index.toString()),
        e,
        dragging: dragging,
        y: (index == 0 ? index * (itemHeight) : index * (itemHeight + gap)),
      );
      index++;
      return item;
    }).toList();

    return items;
  }

  List<Widget> get children => view.children;
  double get itemHeight => view.itemHeight;
  double get gap => view.gap;

  setY(double y) {
    changeY = y;
    for (var item in items) {
      item.setY(context, changeY);

      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }
}
