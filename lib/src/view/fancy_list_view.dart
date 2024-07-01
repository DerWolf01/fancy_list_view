import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';

import 'package:fancy_list_view/src/view/view_stack.dart';
import 'package:flutter/material.dart';

// TODO

// Add different limit animations for end and start ( ILimitReachedAnimation? )
// item gaps satggering up
// list just going with the touch but moving back on end
// list just stayin where it is

// Fix scrollTo aniomation when removing item

// Fix magentic scroll

// Add staggered scroll

// structure on scroll and lifecycle hook animation implementation
// Add immediate animated enter and leave for items
// add onAdd and onRemove animation
// Add Dismissible implementation

// Structure code and ensure code quality
// make list compatible for y and x axis
class FancyListView extends StatefulWidget {
  FancyListView(
      {required this.children,
      required this.height,
      required this.itemHeight,
      FancyListController? controller,
      this.clipBehavior,
      this.decoration,
      super.key})
      : controller = controller ?? FancyListController();

  final List<Widget> children;
  final double gap = 15.0;
  final FancyListController controller;
  final double height;
  final double itemHeight;

  final Clip? clipBehavior;
  final BoxDecoration? decoration;

  @override
  State<StatefulWidget> createState() => FancyListViewState();
}

class FancyListViewState extends State<FancyListView> {
  List<Widget> get children => widget.children;
  double get gap => widget.gap;
  FancyListController get controller => widget.controller;
  double get height => widget.height;
  double get itemHeight => widget.itemHeight;

  final ValueNotifier<double> _y = ValueNotifier(0.0);
  final ValueNotifier<bool> _dragging = ValueNotifier(false);

  Clip? get clipBehavior => widget.clipBehavior;
  BoxDecoration? get decoration => widget.decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        clipBehavior: clipBehavior ?? Clip.none,
        decoration: decoration ?? const BoxDecoration(),
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
                builder: (context, dragging, c) => FancyListStack(widget))));
  }
}
