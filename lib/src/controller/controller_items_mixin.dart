import 'package:fancy_list_view/src/controller/types.dart';
import 'package:fancy_list_view/src/fancy_list_item.dart';

mixin class FancyListControllerItemsMixin {
  Items items = [];

  FancyListItem? item(int index) => items
      .where(
        (element) => element.index == index,
      )
      .firstOrNull;

  Items itemsUpwards(int index) =>
      items.where((element) => element.index > index).toList();

  Items itemsDownwards(int index) =>
      items.where((element) => element.index < index).toList();

  void removeAt(int index) {
    print(items);
    print(items.map(
      (e) => e.index,
    ));
    items.removeWhere(
      (element) => element.index == index,
    );

    items = items.map((e) {
      if (e.index > index) {
        e.decreaseIndex();
        e.isLastItem = isLastItem(index);
      }
      return e;
    }).toList();
    print(items);
    print(items.map(
      (e) => e.index,
    ));
  }

  bool isLastItem(int index) => items.length - 1 == index;
}
