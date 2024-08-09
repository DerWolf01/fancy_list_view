import 'dart:math';
import 'dart:ui';

import 'package:advanced_change_notifier/advanced_change_notifier.dart';
import 'package:fancy_list_view/main.dart';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/controller/controller_items_mixin.dart';
import 'package:fancy_list_view/src/controller/limit/limit_interface.dart';
import 'package:fancy_list_view/src/controller/types.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:fancy_list_view/src/list_widget_change_notifier/list_widget_change_notifier.dart';
import 'package:fancy_list_view/src/view/view_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum DragDirection { up, down }

class FancyListController
    with
        ListWidgetChangeNotifier<FancyListItem>,
        FancyListControllerItemsMixin {
  FancyListController._internal({OverscrollHandler? overscrollHandler}) {
    this.overscrollHandler =
        overscrollHandler ?? PlainOverscroll(controller: this);
  }

  static FancyListController? _instance;

  factory FancyListController({OverscrollHandler? overscrollHandler}) {
    _instance ??=
        FancyListController._internal(overscrollHandler: overscrollHandler);
    return _instance!;
  }
  late final OverscrollHandler overscrollHandler;
  ValueNotifier<bool> dragging = ValueNotifier(false);
  double listContentHeight = 0.0;
  double listHeight = .0;
  late FancyListView view;

  double changeY = 0.0;
  GlobalKey<FancyListStackState>? globalKey;
  BuildContext get context => globalKey!.currentState!.context;

  bool isOverscrolling = false;

  overscrolling() => isOverscrolling = true;
  notOverscrolling() => isOverscrolling = true;

  FancyListItem mockItem(
    int index,
  ) =>
      FancyListItem(Text(Random().nextDouble().toString()),
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
          listHeight: listHeight,
          height: itemHeight,
          initialChangeY: changeY,
          y: (index == 0 ? index * (itemHeight) : index * (itemHeight + gap)));

  scrollTo(int index) {
    var item = items
        .where(
          (element) => element.index == index,
        )
        .first;
    if (index == 0) {
      setY(-(item.movementHandler.baseY.value));
    } else {
      setY(-(item.movementHandler.baseY.value - item.height));
    }
  }

  scrollToStart() {
    setY(0);
  }

  scrollToEnd() {
    setY(-lastItem.movementHandler.endTillEnd);
  }

  void insert(Widget item) {
    var newItem = mockItem(0);
    for (var current in items) {
      current.increaseIndex();
      current.movementHandler.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

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
      current.movementHandler.baseY.value += newItem.height + gap;
    }
    items.add(newItem);

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
    toRemove.movementHandler.leave(context);

    super.removeAt(index);
    for (var item in itemsUpwards(index - 1)) {
      item.movementHandler.baseY.value -= toRemove.height + gap;
    }

    notifyRemoveListeners(index);
  }

  void increaseBaseY(double y, {int? from}) {
    var items =
        this.items.getRange(from ?? 0, this.items.length).toList().reversed;
    for (var item in items) {
      item.movementHandler.baseY.value += y;
      // print("moving ${item.key} - ${item.onScreen()}");
    }
  }

  void moveY(
    double y,
  ) {
    if (overscrollHandler.isOverscrollingTop) {
      overscrollHandler.onOverscrollTop(y);
      print("overscrolling top");
      return;
    } else if (overscrollHandler.isOverscrollingBottom) {
      print("overscrolling bottom");

      overscrollHandler.onOverscrollBottom(y);
      return;
    } else {
      changeY += y;
      final direction = y > 0 ? DragDirection.down : DragDirection.up;
      if (direction == DragDirection.up) {
        for (var item in items.reversed) {
          if (!item.moveY(context, y, animated: false)) {
            break;
          }
          // print("moving ${item.index} - ${item.onScreen()}");
        }
      } else if (direction == DragDirection.down) {
        for (var item in items) {
          if (!item.moveY(context, y, animated: false)) {
            break;
          }
          // print("moving ${item.index} - ${item.onScreen()}");
        }
      }
    }
  }

  void endY() {
    if (overscrollHandler.isOverscrollingTop) {
      overscrollHandler.overscrollingTopStop();
      return;
    } else if (overscrollHandler.isOverscrollingBottom) {
      overscrollHandler.overscrollingBottomStop();
      return;
    }
    print("move end");
    for (var item in items) {
      item.moveYEnd(context);
      // print("moving ${item.key} - ${item.onScreen()}");
    }
    dragging.value = false;
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
          x: (context) => 355,
          scale: (c, progress) => 1 - progress * 1,
        ),
        listHeight: height,
        height: itemHeight,
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
      item.moveY(context, item.changeY.value - changeY);
    }
  }

  FancyListItem get lastItem => items.firstWhere(
        (element) => element.index == items.length - 1,
      );

  FancyListItem get firstItem => items
      .where(
        (element) => element.isFirstItem,
      )
      .first;
}
