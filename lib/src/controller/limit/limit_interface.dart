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

class PlainOverscroll extends OverscrollHandler {
  PlainOverscroll({required super.controller});
  double change = 0.0;

  @override
  onOverscrollTop(double overscroll) {}

  @override
  onOverscrollTopEnd() {}

  @override
  onOverscrollBottom(double overscroll) {}

  @override
  onOverscrollBottomEnd() {}

  @override
  onOverscrollBottomStart() {}

  @override
  onOverscrollTopStart() {}
}
