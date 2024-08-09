import 'dart:math';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      MovementHandler? movementHandler,
      this.animationType = AnimationionEvent.event,
      bool? animateOnEnter,
      bool? animateOnTrigger})
      : animateOnEnter = animateOnEnter ?? false,
        animateOnTrigger = animateOnTrigger ?? false,
        changeY = ValueNotifier(initialChangeY ?? 0.0),
        movementHandler = movementHandler ??
            ProgressMovementHandler(
                animateOnEnter: animateOnEnter ?? false,
                onEnter: onEnter,
                onLeave: onLeave,
                index: index,
                isLastItem: isLastItem,
                listHeight: listHeight,
                height: height,
                baseY: y);

  final Widget child;
  MovementHandler movementHandler;
  bool isLastItem;
  bool get isFirstItem => index == 0;
  int index;
  increaseIndex() => index++;
  decreaseIndex() {
    AnimationStyle();
    index--;
  }

  bool animateOnEnter;
  bool animateOnTrigger;
  AnimationStop onEnter;

  AnimationStop onLeave;
  final double listHeight;
  final double height;

  final FancyListController fancyListController;
  final ValueNotifier<double> changeY;
  final Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  double progress = 0.0;
  AnimationionEvent animationType;
  bool moveY(BuildContext context, double y, {bool animated = true}) {
    return movementHandler.moveY(context, y, animated: animated);
  }

  setY(BuildContext context, double y) {
    movementHandler.setY(context, y);
  }

  moveYEnd(
    BuildContext context,
  ) {
    // if (progress > 0.25 && !startUnderEnd && endUnderEnd) {
    //   print("end progress $progress $startTillEnd");
    //   x.value = onEnter.x(context);
    //   scale.value = onEnter.scale(context, progress);
    //   fancyListController.moveY(height * progress);

    //   return;
    // }

    // x.value = onLeave.x(context);
    // scale.value = onLeave.scale(context, progress);
    // fancyListController.moveY((height * progress));

    return movementHandler.moveYEnd(context);
  }

  resetValues(BuildContext context) {
    movementHandler.resetValues(context);
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

  bool onScreen() {
    return movementHandler.onScreen();
  }

  @override
  Widget build(BuildContext context) {
    return movementHandler.build(
      context,
      builder: (
              {required baseY,
              required changeY,
              required dragging,
              required scale,
              required x}) =>
          child,
    );
  }
}

enum AnimationionEvent { event, scrollProgress }

abstract class MovementHandler {
  MovementHandler(
      {required this.listHeight,
      required this.height,
      required double baseY,
      required this.index,
      required this.isLastItem,
      this.animateOnEnter = false,
      this.onEnter,
      this.onLeave})
      : baseY = ValueNotifier(baseY);
  AnimationStop? onEnter;
  AnimationStop? onLeave;
  bool animateOnEnter;
  double listHeight;
  double height;
  bool isLastItem;
  bool get isFirstItem => index == 0;
  int index;

  final ValueNotifier<double> baseY;

  bool moveY(BuildContext context, double y, {bool animated = true});
  setY(BuildContext context, double y);
  getX(BuildContext context, double progress, AnimationStops stops);
  moveYEnd(BuildContext context);
  resetValues(BuildContext context);
  onLeaveTopBeginn(BuildContext context);
  onLeaveTopEnd(BuildContext context);
  onLeaveBottomBeginn(BuildContext context);
  onLeaveBottomEnd(BuildContext context);
  whileLeavingStart(BuildContext context);
  whileLeavingEnd(BuildContext context);
  whileLeaving(BuildContext context);
  onScreen();
  enter(BuildContext context);
  leave(BuildContext context);
  ValueNotifier<double> x = ValueNotifier(0.0);
// item start to list start
  bool get endOverStart => endTillStart < 0;
  double get endTillStartP => endTillStart / baseEndTillStart;
  double get endTillStart => 0 + endY;
// item start to list start
  bool get startOverStart => startTillStart < 0;
  double get startTillStartP => startTillStart / baseStartTillStart;
  double get startTillStart => 0 + startY;
// item start to list end
  bool get startUnderEnd => startTillEnd < 0;
  double get startTillEndP => startTillEnd / baseStartTillEnd;
  double get startTillEnd => listHeight - startY;

// item end to list end
  bool get endUnderEnd => endTillEnd < 0;
  double get endTillEndP => endTillEnd / baseEndTillEnd;
  double get endTillEnd => listHeight - endY;

  double get startY => y;
  double get endY => y + height;
  double get y => (changeY.value) + baseY.value;

  double futureEndTillEnd(double withY) => listHeight - (y + height + withY);
  double futureStartTillStart(double withY) => startY + withY;
  final FancyListController fancyListController = FancyListController();
  final ValueNotifier<double> changeY = ValueNotifier(0.0);
  final Color color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  late double baseEndTillEnd;
  late double baseStartTillEnd;
  late double baseEndTillStart;
  late double baseStartTillStart;

  final ValueNotifier<double> scale = ValueNotifier(1.0);

  bool get leavingStart => !endOverStart && startOverStart;
  bool get leavingEnd => endUnderEnd && !startUnderEnd;

  bool get visible => !startUnderEnd && !endOverStart;
  bool get insideBox =>
      !endUnderEnd && !startUnderEnd && !startOverStart && !endOverStart;

  double progress = 0.0;

  Widget build(BuildContext context,
      {required Widget Function(
              {required bool dragging,
              required double? changeY,
              required double x,
              required double baseY,
              required double scale})
          builder}) {
    baseEndTillEnd = baseY.value + height - listHeight;
    baseEndTillStart = baseY.value + height + listHeight;
    baseStartTillStart = baseY.value + listHeight;
    baseStartTillEnd = baseY.value - listHeight;
    x = ValueNotifier(onEnter?.x(context) ?? 0);
    if (animateOnEnter) {
      x.value = onLeave?.x(context) ?? 0;
      scale.value = onEnter?.scale(context, 0.0) ?? 1;
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Future.delayed(
            Duration(milliseconds: (355 / 2).toInt()),
            () {
              x.value = onEnter?.x(context) ?? 0;
              scale.value = onEnter?.scale(context, 1.0) ?? 1;
              animateOnEnter = false;
            },
          );
        },
      );
    }
    return ValueListenableBuilder(
        valueListenable: FancyListController().dragging,
        builder: (context, dragging, _) => ValueListenableBuilder(
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
                        transform:
                            Matrix4.translationValues(x, baseY + changeY, 0),
                        child: ValueListenableBuilder(
                            valueListenable: scale,
                            builder: (context, scale, child) => AnimatedScale(
                                scale: scale,
                                duration:
                                    Duration(milliseconds: dragging ? 0 : 355),
                                child: builder(
                                    baseY: baseY,
                                    changeY: changeY,
                                    dragging: dragging,
                                    scale: scale,
                                    x: x))))))));
  }
}

class ProgressMovementHandler extends MovementHandler {
  ProgressMovementHandler(
      {required super.listHeight,
      required super.height,
      required super.baseY,
      required super.index,
      required super.isLastItem,
      super.animateOnEnter,
      super.onEnter,
      super.onLeave});

  @override
  enter(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 355 ~/ 2),
      () {
        x.value = onEnter?.x(context) ?? 0;
        scale.value = onEnter?.scale(context, 1.0) ?? 1;
      },
    );
  }

  @override
  leave(BuildContext context) {
    x.value = onLeave?.x(context) ?? 0;
    scale.value = onEnter?.scale(context, 1.0) ?? 1;
  }

  @override
  setY(BuildContext context, double y) {
    if (visible) {
      resetValues(context);
    }

    changeY.value = y;
  }

  @override
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

  @override
  bool moveY(BuildContext context, double y, {bool animated = true}) {
    // print(futureEndTillEnd);
    // if (futureStartTillStart >= 0) {
    //   fancyListController.overscrollHandler.overscrollingTopStop();
    // } else if (futureEndTillEnd >= 0) {
    //   fancyListController.overscrollHandler.overscrollingBottomStop();
    // }

    if (isFirstItem) {
      final futureStartTillStart = this.futureStartTillStart(y);
      if (futureStartTillStart >= 0) {
        print("futureStartTillStart $futureStartTillStart");
        fancyListController.overscrollHandler.overscrollingTop();
        resetValues(context);

        return false;
      }
    }
    if (isLastItem) {
      final futureEndTillEnd = this.futureEndTillEnd(y);
      if (futureEndTillEnd > 0) {
        print("futureEndTillEnd $futureEndTillEnd");
        fancyListController.overscrollHandler.overscrollingBottom();
        resetValues(context);
        return false;
      }
    }

    if (leavingStart) {
      whileLeavingStart(context);
    } else if (leavingEnd) {
      whileLeavingEnd(context);
    } else if (insideBox) {
      resetValues(context);
    }

    changeY.value += y;
    return true;
  }

  @override
  moveYEnd(BuildContext context) {
    return;
  }

  @override
  onLeaveTopBeginn(BuildContext context) {}

  @override
  onLeaveTopEnd(BuildContext context) {
    resetValues(context);
  }

  @override
  onLeaveBottomBeginn(BuildContext context) {}

  @override
  onLeaveBottomEnd(BuildContext context) {
    resetValues(context);
  }

  @override
  whileLeavingStart(BuildContext context) {
    var rawProgress = ((endTillStart / height) - 1).abs();

    if (rawProgress <= 0 || rawProgress > 1) {
      onLeaveBottomEnd(context);
      return;
    }

    progress = rawProgress;
    if (onEnter != null && onLeave != null) {
      x.value = getX(context, progress, AnimationStops(onEnter!, onLeave!));

      scale.value =
          getScale(context, progress, AnimationStops(onEnter!, onLeave!));
    }
  }

  @override
  whileLeavingEnd(BuildContext context) {
    var rawProgress = (startTillEnd / height);

    if (rawProgress <= 0 || rawProgress >= 1) {
      onLeaveTopEnd(context);
      return;
    }
    progress = (rawProgress - 1).abs();
    if (onEnter != null && onLeave != null) {
      x.value = getX(context, progress, AnimationStops(onEnter!, onLeave!));

      scale.value =
          getScale(context, progress, AnimationStops(onEnter!, onLeave!));
    }
  }

  @override
  whileLeaving(BuildContext context) {
    if (leavingStart) {
      whileLeavingStart(context);
      return;
    }

    whileLeavingEnd(context);
  }

  @override
  onScreen() {
    if (changeY.value + baseY.value + height <= listHeight) {
      return false;
    } else if (changeY.value + baseY.value >= listHeight) {
      return false;
    }
    return true;
  }

  @override
  resetValues(BuildContext context) {
    x.value = onEnter?.x(context) ?? 0;
    scale.value = onEnter?.scale(context, 0.0) ?? 1;
  }
}
