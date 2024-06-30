import 'package:fancy_list_view/src/controller/types.dart';

mixin class ListWidgetChangeNotifier<T> {
  notifyAddListeners(T item) {
    for (var element in onAddListeners) {
      element(item);
    }
  }

  notifyRemoveListeners(int index) {
    for (var element in onRemoveListeners) {
      element(index);
    }
  }

  List<OnAddListenerType<T>> onAddListeners = [];
  List<OnRemoveListenerType> onRemoveListeners = [];

  createOnAddListener(OnAddListenerType listener) =>
      onAddListeners.add(listener);

  removeOnAddListener(OnAddListenerType listener) => onAddListeners.removeWhere(
        (element) => element == listener,
      );
  createOnRemoveListener(OnRemoveListenerType listener) =>
      onRemoveListeners.add(listener);

  removeOnRemoveListener(OnRemoveListenerType listener) =>
      onRemoveListeners.removeWhere(
        (element) => element == listener,
      );
}
