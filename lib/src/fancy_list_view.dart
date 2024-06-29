import 'package:fancy_list_view/src/controller/fancy_list_controller.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';
import 'package:flutter/material.dart';
// TODO

// Add limits for list reaching end and start
// Implement functionality to add items add prefered index
// Implement functionality to remove items add prefered index

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
  bool initialized = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(items != null ? "items initialized" : "items not initialized");

    // if (!initialized) {
    //   items ??= controller.onInit(context, widget, height);
    //   initialized = true;
    // }
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

class FancyListStack extends StatefulWidget {
  FancyListStack(
    this.view,
  );

  final FancyListView view;
  @override
  final GlobalKey<FancyListStackState> key = GlobalKey();
  @override
  State<StatefulWidget> createState() => FancyListStackState();
}

class FancyListStackState extends State<FancyListStack> {
  List<FancyListItem>? items;

  final GlobalKey<FancyListStackState> key = GlobalKey();
  @override
  void initState() {
    super.initState();

    items = widget.view.controller
        .onInit(widget.view, widget.key, widget.view.height);
    controller.createOnAddListener(
      (value) async {
        print("new item: $value: {height: ${value?.height}, y: ${value?.y}}");
        if (value == null) {
          return;
        }
        setState(() {
          items = controller.items;
        });
      },
    );

    controller.createOnRemoveListener(
      (index) {
        items!.removeWhere(
          (element) => element.index == index,
        );
      },
    );
  }

  FancyListController get controller => widget.view.controller;
  @override
  Widget build(BuildContext context) {
    return Stack(children: items!);
  }
}

class MediaQueryHelper {
  static heightOf(BuildContext context) => MediaQuery.sizeOf(context).height;
  static widthOf(BuildContext context) => MediaQuery.sizeOf(context).height;
}
