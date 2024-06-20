import 'dart:math';
import 'package:flutter/material.dart';

class FancyListItem extends StatelessWidget {
  FancyListItem(this.child,
      {super.key,
      required this.height,
      required this.listHeight,
      required double y,
      required this.dragging})
      : baseY = ValueNotifier(y);
  final Widget child;

  final double listHeight;
  final double height;
  final ValueNotifier<double> baseY;
  final ValueNotifier<double> changeY = ValueNotifier(0.0);
  Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  late final double baseEndTillEnd;
  late final double baseStartTillEnd;
  late final double baseEndTillStart;
  late final double baseStartTillStart;
  final bool dragging;
  final ValueNotifier<double> scale = ValueNotifier(1.0);
  moveY(double y) {
    changeY.value += y;
    print(endY);
    // if (endY > 0) {
    //   print("over the end $key");
    // }

    print("${startTillStart}% till end for $key");
  }

// item start to list start
  double get endTillStartP => endTillStart / baseEndTillStart;
  double get endTillStart => 0 - endY;
// item start to list start
  double get startTillStartP => startTillStart / baseStartTillStart;
  double get startTillStart => 0 - startY;
// item start to list end
  double get startTillEndP => startTillEnd / baseStartTillEnd;
  double get startTillEnd => listHeight - startY;

// item end to list end
  double get endTillEndP => endTillEnd / baseEndTillEnd;
  double get endTillEnd => listHeight - endY;

  double get startY => y;
  double get endY => y + height;
  double get y => changeY.value + baseY.value;
  bool onScreen() {
    print(listHeight);
    if (changeY.value + baseY.value + height <= listHeight) {
      return false;
    } else if (changeY.value + baseY.value >= listHeight) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    baseEndTillEnd = baseY.value + height - listHeight;
    baseEndTillStart = baseY.value + height + listHeight;
    baseStartTillStart = baseY.value + listHeight;
    baseStartTillEnd = baseY.value - listHeight;

    print("distance to end => $startTillEnd");
    return ValueListenableBuilder(
        valueListenable: baseY,
        builder: (context, baseY, child) => ValueListenableBuilder(
              valueListenable: changeY,
              builder: (context, changeY, child) => AnimatedContainer(
                height: height,
                curve: Curves.easeOut,
                duration: Duration(milliseconds: dragging ? 0 : 355),
                transform: Matrix4.translationValues(0, baseY + changeY, 0),
                decoration: BoxDecoration(color: color),
                child: child,
              ),
            ));
  }
}

class FancyListView extends StatelessWidget {
  FancyListView(
      {required this.children,
      required this.height,
      required this.itemHeight,
      this.clipBehavior,
      this.decoration,
      super.key});

  final List<Widget> children;
  final double gap = 15.0;
  final FancyListController controller = FancyListController();
  final double height;
  final double itemHeight;

  final ValueNotifier<double> _y = ValueNotifier(0.0);
  final ValueNotifier<bool> _dragging = ValueNotifier(false);
  late final bool scrollabe = true;

  final Clip? clipBehavior;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    var items = controller.onInit(context, this, _dragging.value, height);

    return Container(
        height: height,
        clipBehavior: clipBehavior ?? Clip.none,
        decoration: decoration,
        child: GestureDetector(
            onVerticalDragStart: (details) => (d) => _dragging.value = true,
            onVerticalDragUpdate: (details) {
              for (var item in items) {
                item.moveY(details.delta.dy);
                print("moving ${item.key} - ${item.onScreen()}");
              }
            },
            child: ValueListenableBuilder(
                valueListenable: _dragging,
                builder: (context, dragging, c) => Stack(children: items))));
  }
}

class MediaQueryHelper {
  static heightOf(BuildContext context) => MediaQuery.sizeOf(context).height;
  static widthOf(BuildContext context) => MediaQuery.sizeOf(context).height;
}

class FancyListController {
  late FancyListView view;
  List<FancyListItem> items = [];
  List<FancyListItem> onInit(
      BuildContext context, FancyListView view, bool dragging, double height) {
    this.view = view;

    int index = 0;

    items = children.map((e) {
      var item = FancyListItem(
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
}
