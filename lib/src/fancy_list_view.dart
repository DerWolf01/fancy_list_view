import 'dart:math';
import 'package:flutter/material.dart';
// TODO
// Add X aniamtion ability
// Add limits for list reaching end and start 
// Implement functionality to add items add prefered index
// Implement functionality to remove items add prefered index

typedef AnimationValueGenerator<T> = T Function(BuildContext context);
typedef AnimationValueGeneratorWithProgress<T> = T Function(
    BuildContext context, double progress);

class AnimationStop<KeyType> {
  const AnimationStop(
      {required this.key, required this.x, required this.scale, this.width});
  final KeyType key;
  final AnimationValueGenerator<double> x;
  // final AnimationValueGenerator? y;
  // final AnimationValueGenerator? z;
  final AnimationValueGeneratorWithProgress<double> scale;
  final AnimationValueGenerator<double?>? width;
}

class AnimationStops {
  AnimationStops(this.stop1, this.stop2);
  AnimationStop stop1;
  AnimationStop stop2;
}

class FancyListItem extends StatelessWidget {
  FancyListItem(this.child,
      {super.key,
      required this.onEnter,
      required this.onLeave,
      required this.height,
      required this.listHeight,
      required double y,
      required this.dragging})
      : baseY = ValueNotifier(y);
  final Widget child;
  AnimationStop onEnter;
  AnimationStop onLeave;
  final double listHeight;
  final double height;
  final ValueNotifier<double> baseY;
  final ValueNotifier<double> changeY = ValueNotifier(0.0);
  final Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  late final double baseEndTillEnd;
  late final double baseStartTillEnd;
  late final double baseEndTillStart;
  late final double baseStartTillStart;
  final bool dragging;
  final ValueNotifier<double> scale = ValueNotifier(1.0);
  bool leavingStart = false;
  bool leavingEnd = false;

  moveY(BuildContext context, double y) {
    changeY.value += y;

    // if (endY > 0) {
    //   print("over the end $key");
    // }

    if (startOverStart) {
      onLeaveTopBeginn();
    } else {
      onLeaveTopEnd();
    }
    if (endOverEnd) {
      onLeaveBottomBeginn();
    } else {
      onLeaveBottomEnd();
    }
    if (leavingEnd || leavingStart) {
      whileLeaving(context);
    }
  }

  onLeaveTopBeginn() {
    leavingStart = true;
  }

  onLeaveTopEnd() {
    leavingStart = false;
  }

  onLeaveBottomBeginn() {
    leavingEnd = true;
  }

  onLeaveBottomEnd() {
    leavingEnd = false;
  }

  whileLeavingStart(BuildContext context) {
    var rawProgress = (endTillStart.abs() / height);
    print(rawProgress);
    if (rawProgress <= 0.05) {
      onLeaveTopEnd();
      return;
    }
    var progress = (rawProgress - 1).abs();
    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
    print(scale.value);
    print("while leaving ");
    print(rawProgress);
  }

  whileLeavingEnd(BuildContext context) {
    var rawProgress = (startTillEnd.abs() / height);
    print(rawProgress);
    if (rawProgress <= 0.05) {
      onLeaveTopEnd();
      return;
    }
    var progress = (rawProgress - 1).abs();

    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
    print("while leaving ");
    print(rawProgress);
  }

  whileLeaving(BuildContext context) {
    if (leavingStart) {
      whileLeavingStart(context);
      return;
    }

    whileLeavingEnd(context);
  }

  Matrix4 translationValues(
      BuildContext context, double progress, AnimationStops stops) {
    var actual = stops.stop1;
    var actualX = actual.x(context);

    var next = stops.stop2;
    var nextX = next.x(context);

    double diff = 0;
    late double res;
    if (actualX.isNegative) {
      diff = nextX - actualX.abs() * progress;
      res = actualX - diff;
    } else {
      res = (nextX - actualX).abs() * progress;
    }

    return Matrix4.translationValues(res, 0, 0);
  }

  double getScale(BuildContext context, double progress, AnimationStops stops) {
    var fScale = stops.stop1.scale(context, progress);
    var sScale = stops.stop2.scale(context, progress);
    return fScale - (fScale - sScale) * progress;
  }

// item start to list start
  bool get endOverStart => endTillStart > 0;
  double get endTillStartP => endTillStart / baseEndTillStart;
  double get endTillStart => 0 - endY;
// item start to list start
  bool get startOverStart => startTillStart > 0;
  double get startTillStartP => startTillStart / baseStartTillStart;
  double get startTillStart => 0 - startY;
// item start to list end
  bool get startOverEnd => startTillEnd < 0;
  double get startTillEndP => startTillEnd / baseStartTillEnd;
  double get startTillEnd => listHeight - startY;

// item end to list end
  bool get endOverEnd => endTillEnd < 0;
  double get endTillEndP => endTillEnd / baseEndTillEnd;
  double get endTillEnd => listHeight - endY;

  double get startY => y;
  double get endY => y + height;
  double get y =>
      (changeY.value + changeY.value * (1 - scale.value)) + baseY.value;
  bool onScreen() {
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

    return ValueListenableBuilder(
        valueListenable: scale,
        builder: (context, scale, child) => ValueListenableBuilder(
            valueListenable: baseY,
            builder: (context, baseY, child) => ValueListenableBuilder(
                valueListenable: changeY,
                builder: (context, changeY, child) => AnimatedScale(
                      scale: scale,
                      duration: Duration(milliseconds: dragging ? 0 : 355),
                      child: AnimatedContainer(
                        height: height,
                        curve: Curves.easeOut,
                        duration: Duration(milliseconds: dragging ? 0 : 355),
                        transform: Matrix4.translationValues(
                            translationValues(context, progress, stops),
                            baseY + changeY,
                            0),
                        decoration: BoxDecoration(color: color),
                        child: child,
                      ),
                    ))));
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
                item.moveY(context, details.delta.dy);
                // print("moving ${item.key} - ${item.onScreen()}");
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
        onEnter: AnimationStop(
          key: Key("onEnter"),
          x: (context) => 0.0,
          scale: (c, progress) => 1.0,
        ),
        onLeave: AnimationStop(
          key: Key("onLeave"),
          x: (context) => 0.0,
          scale: (c, progress) => 1 - progress * 0.25,
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
}
