import 'package:fancy_list_view/src/animation_stops.dart';
import 'package:fancy_list_view/src/movement_handler/movement_handler.dart';
import 'package:flutter/material.dart';

class EventMovementHandler extends MovementHandler {
  EventMovementHandler({
    this.percentage = 0.5,
    required super.listHeight,
    required super.height,
    required super.baseY,
    required super.index,
    required super.isLastItem,
    super.animateOnEnter,
    super.onEnter,
    super.onLeave,
  });

  /// The percentage of the height of the item that should be scrolled over the start or end before the item is considered to be left the screen.
  double percentage = 0.5;
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
    print("$startTillStart ${height * percentage}");

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
    if (!leftEnd) {
      if (endTillEnd < -height * percentage) {
        leftEnd = true;
        x.value = onLeave?.x(context) ?? 0;
        scale.value = onLeave?.scale(context, 0.0) ?? 1;
      }
    }
    if (!leftStart) {
      if (startTillStart < -height * percentage) {
        leftStart = true;
        x.value = onLeave?.x(context) ?? 0;
        scale.value = onLeave?.scale(context, 0.0) ?? 1;
      }
    }
    if (leftEnd) {
      if (endTillEnd >= -height * percentage) {
        leftEnd = false;
        x.value = onEnter?.x(context) ?? 0;
        scale.value = onEnter?.scale(context, 0.0) ?? 1;
      }
    }
    if (leftStart) {
      if (startTillStart >= -height * percentage) {
        leftStart = false;
        x.value = onEnter?.x(context) ?? 0;
        scale.value = onEnter?.scale(context, 0.0) ?? 1;
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
    //TODO add hooks
  }

  @override
  whileLeavingEnd(BuildContext context) {}

  @override
  whileLeaving(BuildContext context) {}

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
