import 'dart:math';

import 'package:fancy_list_view/src/animation_stop.dart';
import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:flutter/material.dart';

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
  late bool leftStart;
  late bool leftEnd;
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
    leftEnd = startTillEnd < 0;
    leftStart = endTillStart < 0;
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
