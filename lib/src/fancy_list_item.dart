import 'dart:math';

import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/fancy_list_controller.dart';
import 'package:flutter/material.dart';

class FancyListItem extends StatelessWidget {
  FancyListItem(this.child,
      {super.key,
      required this.onEnter,
      required this.onLeave,
      required this.height,
      required this.listHeight,
      required double y,
      required this.isLastItem,
      required this.index,
      required this.fancyListController,
      required this.dragging})
      : baseY = ValueNotifier(y);
  final Widget child;
  bool isLastItem;
  bool get isFirstItem => index == 0;
  int index;
  AnimationStop onEnter;

  AnimationStop onLeave;
  final double listHeight;
  final double height;
  final ValueNotifier<double> baseY;
  late final ValueNotifier<double> x;
  final FancyListController fancyListController;
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
  double progress = 0.0;
  moveY(BuildContext context, double y) {
    changeY.value += y;

    // if (endY > 0) {
    //   print("over the end $key");
    // }

    if (startOverStart) {
      onLeaveTopBeginn(context);
    } else {
      onLeaveTopEnd(context);
    }
    if (endOverEnd) {
      if (isLastItem) {
        return;
      }
      onLeaveBottomBeginn(context);
    } else {
      onLeaveBottomEnd(context);
    }
    if (leavingEnd || leavingStart) {
      whileLeaving(context);
    }
  }

  moveYEnd(
    BuildContext context,
  ) {
    if (isFirstItem && y > baseY.value) {
      fancyListController.setY(0);
      return;
    }
    if (isLastItem && endOverEnd) {
      fancyListController.setY(-changeY.value * progress);
      return;
    }
    if (leavingEnd) {
      return;
    }
    print("move end y --> $progress");
    if (progress < 0.25) {
      print("Nearer to inside");
      x.value = onEnter.x(context);
      scale.value = onEnter.scale(context, progress);
      fancyListController.setY(changeY.value + (height * progress));

      return;
    }
    print("Nearer to outside");
    x.value = onLeave.x(context);
    scale.value = onLeave.scale(context, progress);
    fancyListController.setY(changeY.value - (height * progress));

    return;
  }

  resetValues(BuildContext context) {
    x.value = onEnter.x(context);
    scale.value = onEnter.scale(context, 0.0);
  }

  onLeaveTopBeginn(BuildContext context) {
    leavingStart = true;
  }

  onLeaveTopEnd(BuildContext context) {
    leavingStart = false;
    resetValues(context);
  }

  onLeaveBottomBeginn(BuildContext context) {
    leavingEnd = true;
  }

  onLeaveBottomEnd(BuildContext context) {
    leavingEnd = false;
    resetValues(context);
  }

  whileLeavingStart(BuildContext context) {
    var rawProgressNegative = (endTillStart / height);

    if (rawProgressNegative >= 0) {
      onLeaveTopEnd(context);
      return;
    }

    var rawProgress = rawProgressNegative.abs();
    print(rawProgress);
    progress = (rawProgress - 1).abs();
    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
    x.value = getX(context, progress, AnimationStops(onEnter, onLeave));
    print(x.value);

    print("while leaving ");
  }

  whileLeavingEnd(BuildContext context) {
    var rawProgress = (startTillEnd.abs() / height);
    print(rawProgress);
    if (rawProgress <= 0) {
      onLeaveTopEnd(context);
      return;
    }
    progress = (rawProgress - 1).abs();
    x.value = getX(context, progress, AnimationStops(onEnter, onLeave));
    print(x.value);
    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
    print("while leaving ");
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

  double getX(BuildContext context, double progress, AnimationStops stops) {
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

    return res;
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
  double get y => (changeY.value) + baseY.value;
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
    x = ValueNotifier(onEnter.x(context));
    return ValueListenableBuilder(
        valueListenable: scale,
        builder: (context, scale, child) => ValueListenableBuilder(
            valueListenable: baseY,
            builder: (context, baseY, child) => ValueListenableBuilder(
                valueListenable: changeY,
                builder: (context, changeY, child) => ValueListenableBuilder(
                    valueListenable: x,
                    builder: (context, x, child) => AnimatedScale(
                          scale: scale,
                          duration: Duration(milliseconds: dragging ? 0 : 355),
                          child: AnimatedContainer(
                            height: height,
                            curve: Curves.easeOut,
                            duration:
                                Duration(milliseconds: dragging ? 0 : 355),
                            transform: Matrix4.translationValues(
                                x, baseY + changeY, 0),
                            decoration: BoxDecoration(color: color),
                            child: child,
                          ),
                        )))));
  }
}
