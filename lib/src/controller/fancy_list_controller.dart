import 'dart:math';

import 'package:advanced_change_notifier/advanced_change_notifier.dart';
import 'package:fancy_list_view/main.dart';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/controller/controller_items_mixin.dart';
import 'package:fancy_list_view/src/controller/types.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:fancy_list_view/src/list_widget_change_notifier/list_widget_change_notifier.dart';
import 'package:fancy_list_view/src/view/view_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FancyListController
    with
        ListWidgetChangeNotifier<FancyListItem>,
        FancyListControllerItemsMixin {
  double listContentHeight = 0.0;
  double listHeight = .0;
  late FancyListView view;

  double changeY = 0.0;
  late final GlobalKey<FancyListStackState> globalKey;
  BuildContext get context => globalKey.currentState!.context;

  FancyListItem mockItem(int index) => (() => FancyListItem(
      Text(Random().nextDouble().toString()),
      animateOnEnter: true,
      isLastItem: index == items.length - 1,
      index: index,
      fancyListController: this,
      onEnter: AnimationStop(
        key: const Key("onEnter"),
        x: (context) => 0.0,
        scale: (c, progress) => 1.0,
      ),
      onLeave: AnimationStop(
        key: const Key("onLeave"),
        x: (context) => MediaQuery.sizeOf(context).width,
        scale: (c, progress) => 1.0,
      ),
      dragging: false,
      listHeight: listHeight,
      height: itemHeight,
      initialChangeY: changeY,
      y: (index == 0 ? index * (itemHeight) : index * (itemHeight + gap))))();

  scrollTo(int index) {
    var item = items
        .where(
          (element) => element.index == index,
        )
        .first;
    if (index == 0) {
      setY(-(item.baseY.value));
    } else {
      setY(-(item.baseY.value - item.height));
    }
  }

  void insert(Widget item) {
    var newItem = mockItem(0);
    for (var current in items) {
      current.increaseIndex();
      current.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

    print(items.map(
      (e) => e.index,
    ));
    scrollTo(newItem.index);
    notifyAddListeners(newItem);
  }

// At an item to specific index
  void insertAt(Widget item, int index) {
    if (itemsDownwards(index).isEmpty) {
      return;
    }
    var newItem = mockItem(index);
    for (var current in items.where(
      (element) => element.index >= index,
    )) {
      current.increaseIndex();
      current.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

    print(items.map(
      (e) => e.index,
    ));
    scrollTo(newItem.index);

    notifyAddListeners(newItem);
  }

// At an item to specific index
  @override
  void removeAt(int index) {
    var toRemove = item(index);
    if (toRemove == null) {
      return;
    }
    scrollTo(index);
    toRemove.leave(context);

    super.removeAt(index);
    for (var item in itemsUpwards(index - 1)) {
      item.baseY.value -= toRemove.height + gap;
    }

    print(items.map(
      (e) => e.index,
    ));

    notifyRemoveListeners(index);
  }

  void increaseBaseY(double y, {int? from}) {
    var items =
        this.items.getRange(from ?? 0, this.items.length).toList().reversed;
    for (var item in items) {
      item.baseY.value += y;
      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }

  void moveY(double y) {
    changeY += y;
    for (var item in items) {
      print(item.index);
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

  Items onInit(FancyListView view, GlobalKey<FancyListStackState> globalKey,
      double height) {
    this.globalKey = globalKey;
    listContentHeight = view.children.length * view.itemHeight;

    this.view = view;
    listHeight = height;
    int index = 0;

    items = children.map((e) {
      var item = FancyListItem(
        e,
        // key: uniqueKey,
        animateOnEnter: false,
        isLastItem: index == view.children.length - 1,
        index: index,
        fancyListController: this,
        onEnter: AnimationStop(
          key: const Key("onEnter"),
          x: (context) => 0.0,
          scale: (c, progress) => 1.0,
        ),
        onLeave: AnimationStop(
          key: const Key("onLeave"),
          x: (context) => 0,
          scale: (c, progress) => 1 - progress * 1,
        ),
        listHeight: height,
        height: itemHeight,
        // key: Key(index.toString()),
        dragging: false,
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
    }
  }

  FancyListController._internal();
  static FancyListController? _instance;

  factory FancyListController() {
    _instance ??= FancyListController._internal();
    return _instance!;
  }
}
