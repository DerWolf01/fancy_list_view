import 'package:fancy_list_view/src/fancy_list_controller.dart';
import 'package:flutter/material.dart';
// TODO

// Add limits for list reaching end and start
// Implement functionality to add items add prefered index
// Implement functionality to remove items add prefered index

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
              controller.moveY(details.delta.dy);
            },
            onVerticalDragEnd: (details) {
              controller.endY();
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
