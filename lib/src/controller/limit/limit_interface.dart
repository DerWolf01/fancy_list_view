import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';

abstract class OverscrollHandler {
  OverscrollHandler({required this.controller});

  bool isOverscrollingTop = false;
  bool isOverscrollingBottom = false;

  overscrollingTop() {
    isOverscrollingTop = true;
    onOverscrollTopStart();
  }

  overscrollingBottom() {
    isOverscrollingBottom = true;
    onOverscrollBottomStart();
  }

  overscrollingTopStop() {
    onOverscrollTopEnd();
    isOverscrollingTop = false;
  }

  overscrollingBottomStop() {
    onOverscrollBottomEnd();
    isOverscrollingBottom = false;
  }

  FancyListController controller;

  onOverscrollTopStart();
  onOverscrollTop(double overscroll);
  onOverscrollTopEnd();

  onOverscrollBottomStart();
  onOverscrollBottom(double overscroll);
  onOverscrollBottomEnd();
}

class OverscrollStandartHandler extends OverscrollHandler {
  OverscrollStandartHandler({required super.controller});
  double change = 0.0;

  @override
  onOverscrollTop(double overscroll) {
    var y = overscroll * 0.1;
    if (change + y <= 0) {
      overscrollingTopStop();
      controller.moveY(y);
      return;
    }
    change += y;
    controller.changeY += y;

    for (var item in controller.items) {
      var itemChange = y * (item.index * 0.3);
      item.moveY(controller.context, itemChange, animated: false);
    }
  }

  @override
  onOverscrollTopEnd() {
    controller.changeY += change;
    var items = [...controller.items];
    // items.removeWhere(
    //   (element) => element.index == 0,
    // );
    for (var item in items) {
      item.moveY(controller.context, -item.changeY.value, animated: false);
    }
    change = 0.0;
  }

  @override
  onOverscrollBottom(double overscroll) {
    var y = overscroll * 0.1;
    if (change + y <= 0) {
      overscrollingBottomStop();
      controller.moveY(y);
      return;
    }
    change -= y;
    controller.changeY -= y;

    for (var item in controller.items) {
      item.moveY(controller.context, y, animated: false);
    }
  }

  @override
  onOverscrollBottomEnd() {
    controller.changeY += change;
    for (var item in controller.items) {
      item.moveY(controller.context, change, animated: false);
    }
    change = 0.0;
  }

  @override
  onOverscrollBottomStart() {
    controller.lastItem.resetValues(controller.context);
  }

  @override
  onOverscrollTopStart() {
    controller.firstItem.resetValues(controller.context);
  }
}
