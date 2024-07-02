import 'dart:math';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FancyListItem extends StatelessWidget {
  FancyListItem(this.child,
      {super.key,
      required this.onEnter,
      required this.onLeave,
      required this.height,
      required this.listHeight,
      required double y,
      double? initialChangeY,
      required this.isLastItem,
      required this.index,
      required this.fancyListController,
      required this.dragging,
      bool? animateOnEnter,
      bool? animateOnTrigger})
      : baseY = ValueNotifier(y),
        animateOnEnter = animateOnEnter ?? false,
        animateOnTrigger = animateOnTrigger ?? false,
        changeY = ValueNotifier(initialChangeY ?? 0.0);

  final Widget child;
  bool isLastItem;
  bool get isFirstItem => index == 0;
  int index;
  increaseIndex() => index++;
  decreaseIndex() {
    index--;
  }

  bool animateOnEnter;
  bool animateOnTrigger;
  AnimationStop onEnter;

  AnimationStop onLeave;
  final double listHeight;
  final double height;
  final ValueNotifier<double> baseY;
  ValueNotifier<double> x = ValueNotifier(0.0);
  final FancyListController fancyListController;
  final ValueNotifier<double> changeY;
  final Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  late double baseEndTillEnd;
  late double baseStartTillEnd;
  late double baseEndTillStart;
  late double baseStartTillStart;
  final bool dragging;
  final ValueNotifier<double> scale = ValueNotifier(1.0);

  bool get leavingStart => !endOverStart && startOverStart;
  bool get leavingEnd => endOverEnd && !startOverEnd;

  bool get visible => !startOverEnd && !endOverStart;
  bool get insideBox =>
      !endOverEnd && !startOverEnd && !startOverStart && !endOverStart;

  double progress = 0.0;

  moveY(BuildContext context, double y, {bool animated = true}) {
    var futureStartTillStart = this.futureStartTillStart(y);
    var futureEndTillEnd = this.futureEndTillEnd(y);
    // if (futureStartTillStart >= 0) {
    //   fancyListController.overscrollHandler.overscrollingTopStop();
    // } else if (futureEndTillEnd >= 0) {
    //   fancyListController.overscrollHandler.overscrollingBottomStop();
    // }
    if (animated == false) {
      changeY.value += y;
      print("not animated");
      return;
    }
    if (isFirstItem && futureStartTillStart > 0) {
      fancyListController.overscrollHandler.overscrollingTop();
      return;
    }
    if (isLastItem && futureEndTillEnd > 0) {
      fancyListController.overscrollHandler.overscrollingBottom();

      return;
    }

    if (leavingStart) {
      whileLeavingStart(context);
    } else if (leavingEnd) {
      whileLeavingEnd(context);
    } else if (insideBox) {
      resetValues(context);
    }

    changeY.value += y;
  }

  setY(BuildContext context, double y) {
    if (visible) {
      resetValues(context);
    }

    changeY.value = y;
  }

  moveYEnd(
    BuildContext context,
  ) {
    if (progress > 0.25) {
      x.value = onEnter.x(context);
      scale.value = onEnter.scale(context, progress);
      fancyListController.moveY(-height / 2 * progress);

      return;
    }

    x.value = onLeave.x(context);
    scale.value = onLeave.scale(context, progress);
    fancyListController.moveY((height * progress));

    return;
  }

  resetValues(BuildContext context) {
    x.value = onEnter.x(context);
    scale.value = onEnter.scale(context, 0.0);
  }

  onLeaveTopBeginn(BuildContext context) {}

  onLeaveTopEnd(BuildContext context) {
    resetValues(context);
  }

  onLeaveBottomBeginn(BuildContext context) {}

  onLeaveBottomEnd(BuildContext context) {
    resetValues(context);
  }

  whileLeavingStart(BuildContext context) {
    var rawProgress = ((endTillStart / height) - 1).abs();
    // print(rawProgress);

    if (rawProgress <= 0 || rawProgress > 1) {
      onLeaveBottomEnd(context);
      return;
    }

    progress = rawProgress;

    print(rawProgress);

    // print(progress);
    x.value = getX(context, progress, AnimationStops(onEnter, onLeave));

    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
  }

  whileLeavingEnd(BuildContext context) {
    if (isLastItem) {
      print(endOverEnd);
    }
    var rawProgress = (startTillEnd / height);
    if (isLastItem) {
      print(rawProgress);
    }
    if (rawProgress <= 0 || rawProgress > 1) {
      onLeaveTopEnd(context);
      return;
    }
    progress = (rawProgress - 1).abs();
    x.value = getX(context, progress, AnimationStops(onEnter, onLeave));

    scale.value = getScale(context, progress, AnimationStops(onEnter, onLeave));
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

  bool onScreen() {
    if (changeY.value + baseY.value + height <= listHeight) {
      return false;
    } else if (changeY.value + baseY.value >= listHeight) {
      return false;
    }
    return true;
  }

  enter(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 355 ~/ 2),
      () {
        x.value = onEnter.x(context);
        scale.value = onEnter.scale(context, 1.0);
      },
    );
  }

  leave(BuildContext context) {
    x.value = onLeave.x(context);
    scale.value = onEnter.scale(context, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    baseEndTillEnd = baseY.value + height - listHeight;
    baseEndTillStart = baseY.value + height + listHeight;
    baseStartTillStart = baseY.value + listHeight;
    baseStartTillEnd = baseY.value - listHeight;
    x = ValueNotifier(onEnter.x(context));
    if (animateOnEnter) {
      x.value = onLeave.x(context);
      scale.value = onEnter.scale(context, 0.0);
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Future.delayed(
            Duration(milliseconds: (355 / 2).toInt()),
            () {
              x.value = onEnter.x(context);
              scale.value = onEnter.scale(context, 1.0);
              animateOnEnter = false;
            },
          );
        },
      );
    } else if (animateOnTrigger) {
      resetValues(context);
    }
    return ValueListenableBuilder(
        valueListenable: changeY,
        builder: (context, changeY, child) => ValueListenableBuilder(
            valueListenable: x,
            builder: (context, x, child) => ValueListenableBuilder(
                valueListenable: baseY,
                builder: (context, baseY, child) => AnimatedContainer(
                    width: double.infinity,
                    height: height,
                    curve: Curves.easeOut,
                    duration: Duration(milliseconds: dragging ? 0 : 355),
                    transform: Matrix4.translationValues(x, baseY + changeY, 0),
                    child: ValueListenableBuilder(
                      valueListenable: scale,
                      builder: (context, scale, child) => AnimatedScale(
                        scale: scale,
                        duration: Duration(milliseconds: dragging ? 0 : 355),
                        child: this.child,
                      ),
                    )))));
  }

// item start to list start
  bool get endOverStart => endTillStart < 0;
  double get endTillStartP => endTillStart / baseEndTillStart;
  double get endTillStart => 0 + endY;
// item start to list start
  bool get startOverStart => startTillStart < 0;
  double get startTillStartP => startTillStart / baseStartTillStart;
  double get startTillStart => 0 + startY;
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

  double futureEndTillEnd(double withY) => listHeight - (y + height + withY);
  double futureStartTillStart(double withY) => startY + withY;
}
