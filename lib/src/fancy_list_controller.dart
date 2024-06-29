import 'dart:math';

import 'package:advanced_change_notifier/advanced_change_notifier.dart';
import 'package:fancy_list_view/main.dart';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef OnAddListenerType<T> = void Function(T item);
typedef OnRemoveListenerType = void Function(int index);

class ListWidgetChangeNotifier<T> {
  notifyAddListeners(T item) {
    for (var element in onAddListeners) {
      element(item);
    }
  }

  notifyRemoveListeners(int index) {
    for (var element in onRemoveListeners) {
      element(index);
    }
  }

  List<OnAddListenerType<T>> onAddListeners = [];
  List<OnRemoveListenerType> onRemoveListeners = [];

  createOnAddListener(OnAddListenerType listener) =>
      onAddListeners.add(listener);

  removeOnAddListener(OnAddListenerType listener) => onAddListeners.removeWhere(
        (element) => element == listener,
      );
  createOnRemoveListener(OnRemoveListenerType listener) =>
      onRemoveListeners.add(listener);

  removeOnRemoveListener(OnRemoveListenerType listener) =>
      onRemoveListeners.removeWhere(
        (element) => element == listener,
      );
}

class FancyListController extends ListWidgetChangeNotifier<FancyListItem> {
  FancyListController._internal();
  static FancyListController? _instance;

  factory FancyListController() {
    _instance ??= FancyListController._internal();
    return _instance!;
  }

  double listContentHeight = 0.0;
  double listHeight = .0;
  late FancyListView view;
  List<FancyListItem> items = [];
  double changeY = 0.0;
  late final GlobalKey<FancyListStackState> globalKey;
  BuildContext get context => globalKey.currentState!.context;

  // Key get uniqueKey {
  //   var res = Key(Random().nextDouble().toString());

  //   print(res);
  //   return res;
  // }

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

  void addItem(Widget item) {
    var newItem = mockItem(0);
    for (var current in items) {
      current.increaseIndex();
      current.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

    print(items.map(
      (e) => e.index,
    ));
    notifyAddListeners(newItem);
  }

// At an item to specific index
  void addItemAt(Widget item, int index) {
    var newItem = mockItem(index);
    for (var current in items.getRange(index, items.length)) {
      current.increaseIndex();
      current.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

    print(items.map(
      (e) => e.index,
    ));
    notifyAddListeners(newItem);
  }

// At an item to specific index
  void removeItemAt(int index) {
    var toRemove = items[index];

    for (int i = index + 1; i < items.length - 1; i++) {
      var current = items[i];
      current.decreaseIndex();
      current.baseY.value -= toRemove.height + gap;
    }
    items.removeAt(index);

    print(items.map(
      (e) => e.index,
    ));
    notifyRemoveListeners(index);
  }

  List<FancyListItem> itemsFromIndex(int index) {
    List<FancyListItem> res = [];
    for (var i = index; i < items.length - 1; i++) {
      res.add(items[i]);
    }
    return res;
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

  List<FancyListItem> onInit(FancyListView view,
      GlobalKey<FancyListStackState> globalKey, double height) {
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
          x: (context) => MediaQuery.sizeOf(context).width,
          scale: (c, progress) => 1.0,
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

      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }
}
