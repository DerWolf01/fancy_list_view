import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/movement_handler/movement_handler.dart';
import 'package:flutter/material.dart';

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

  double progress = 0.0;
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
