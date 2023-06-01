import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flush_bar/src/helpers/safe_state.dart';

/// 简化的 `ExValueBuilder`
class StateBuilder<T, V> extends StatefulWidget {
  const StateBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    required this.selector,
    this.shouldRebuild,
  })  : child = null,
        childBuilder = null,
        super(key: key);

  const StateBuilder.child({
    Key? key,
    required this.valueListenable,
    required this.childBuilder,
    required this.child,
    required this.selector,
    this.shouldRebuild,
  })  : builder = null,
        super(key: key);

  final ValueListenable<T> valueListenable;

  final Widget? child;

  final Widget Function(V value)? builder;

  final Widget Function(V value, Widget child)? childBuilder;

  /// rebuild触发器
  final V Function(T state) selector;

  final bool Function(T p, T n)? shouldRebuild;

  @override
  State<StatefulWidget> createState() => _StateBuilderState<T, V>();
}

class _StateBuilderState<T, V> extends State<StateBuilder<T, V>> with SafeState<StateBuilder<T, V>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(StateBuilder<T, V> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      _value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    // 条件判断
    final bool isSelected = widget.selector.call(widget.valueListenable.value) != widget.selector.call(_value);
    final bool isValueChanged = widget.shouldRebuild?.call(_value, widget.valueListenable.value) ?? true;

    if (isSelected && isValueChanged) {
      setState(() {
        _value = widget.valueListenable.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child == null) {
      return widget.builder?.call(widget.selector(_value)) ??
          widget.childBuilder?.call(widget.selector(_value), widget.child ?? const SizedBox.shrink()) ??
          const SizedBox.shrink();
    }

    return widget.childBuilder?.call(widget.selector(_value), widget.child!) ?? const SizedBox.shrink();
  }
}
