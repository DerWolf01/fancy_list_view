import 'dart:math';
import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:fancy_list_view/src/movement_handler/event_movement_handler.dart';
import 'package:fancy_list_view/src/movement_handler/movement_handler.dart';
import 'package:fancy_list_view/src/movement_handler/progress_movement_handler.dart';
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
            EventMovementHandler(
                onEnter: onEnter,
                onLeave: onLeave,
                animateOnEnter: animateOnEnter ?? false,
                listHeight: listHeight,
                height: height,
                baseY: y,
                index: index,
                isLastItem: isLastItem);
  // ProgressMovementHandler(
  //     animateOnEnter: animateOnEnter ?? false,
  //     onEnter: onEnter,
  //     onLeave: onLeave,
  //     index: index,
  //     isLastItem: isLastItem,
  //     listHeight: listHeight,
  //     height: height,
  //     baseY: y);

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
