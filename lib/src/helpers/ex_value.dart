import 'package:flutter/material.dart';

import 'builder/ex_value_builder.dart';
import 'builder/state_builder.dart';

typedef ExOnData<T> = Function(T p, T n);

///ValueNotifier安全扩展
class ExValue<T> extends ValueNotifier<T> {
  ExValue(T value) : super(value);

  bool _mounted = true;

  final List<ExOnData<T>> _onDataList = <ExOnData<T>>[];

  void addCallback(ExOnData<T> onData) {
    _onDataList.add(onData);
  }

  void removeCallback(ExOnData<T> onData) {
    _onDataList.remove(onData);
  }

  @override
  set value(T newValue) {
    if (_mounted) {
      if (value != newValue) {
        final T oldValue = value;

        for (final ExOnData<T> onData in _onDataList) {
          try {
            onData(oldValue, newValue);
          } catch (e) {
            debugPrint('call onData error: $e');
          }
        }

        super.value = newValue;
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _onDataList.clear();
    super.dispose();
  }

  Widget build(Widget Function(T value) builder, {bool Function(T p, T n)? shouldRebuild}) {
    return ExBuilder<T>(
      valueListenable: this,
      shouldRebuild: shouldRebuild,
      builder: (T value) {
        return builder(value);
      },
    );
  }

  Widget buildWithChild(
    Widget Function(T value, Widget child) builder, {
    bool Function(T p, T n)? shouldRebuild,
    Widget? child,
  }) {
    return ExBuilder<T>.child(
      valueListenable: this,
      shouldRebuild: shouldRebuild,
      childBuilder: builder,
      child: child,
    );
  }

  Widget buildState<V>({
    required V Function(T) selector,
    bool Function(T p, T n)? shouldRebuild,
    required Widget Function(V, Widget)? builder,
    Widget? child,
  }) {
    return StateBuilder<T, V>.child(
      valueListenable: this,
      selector: selector,
      shouldRebuild: shouldRebuild,
      childBuilder: builder,
      child: child,
    );
  }
}
