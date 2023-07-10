// 拷贝ValueListenableBuilder
// 添加shouldRebuild方法

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_floating_notification/src/helpers/safe_state.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

class ExValueBuilder<T> extends StatefulWidget {
  const ExValueBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.child,
    this.shouldRebuild,
  }) : super(key: key);

  final ValueListenable<T> valueListenable;

  final ValueWidgetBuilder<T> builder;

  final Widget? child;

  ///是否进行重建
  final bool Function(T previous, T next)? shouldRebuild;

  @override
  State<StatefulWidget> createState() => _ExValueBuilderState<T>();
}

class _ExValueBuilderState<T> extends State<ExValueBuilder<T>>
    with SafeState<ExValueBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ExValueBuilder<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
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
    ///条件判断
    if (widget.shouldRebuild == null ||
        widget.shouldRebuild!(value, widget.valueListenable.value)) {
      setState(() {
        value = widget.valueListenable.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}

/// 简化的 `ExValueBuilder`
class ExBuilder<T> extends StatefulWidget {
  const ExBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.shouldRebuild,
  })  : child = null,
        childBuilder = null,
        super(key: key);

  const ExBuilder.child({
    Key? key,
    required this.valueListenable,
    required this.childBuilder,
    required this.child,
    this.shouldRebuild,
  })  : builder = null,
        super(key: key);

  final ValueListenable<T> valueListenable;

  final Widget? child;

  final Widget Function(T value)? builder;

  final Widget Function(T value, Widget child)? childBuilder;

  ///是否进行重建
  final bool Function(T previous, T next)? shouldRebuild;

  @override
  State<StatefulWidget> createState() => _ExBuilderState<T>();
}

class _ExBuilderState<T> extends State<ExBuilder<T>>
    with SafeState<ExBuilder<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ExBuilder<T> oldWidget) {
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
    final bool shouldRebuild =
        widget.shouldRebuild?.call(_value, widget.valueListenable.value) ??
            true;
    if (shouldRebuild) {
      _value = widget.valueListenable.value;
      safeSetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child == null) {
      return widget.builder?.call(_value) ?? const SizedBox.shrink();
    } else {
      return widget.childBuilder?.call(_value, widget.child!) ??
          const SizedBox.shrink();
    }
  }
}

/// 监听器
class ListenBuilder extends StatefulWidget {
  const ListenBuilder({
    Key? key,
    required this.listenable,
    required this.builder,
  })  : childen = null,
        childBuilder = null,
        super(key: key);

  const ListenBuilder.child({
    Key? key,
    required this.listenable,
    required this.childBuilder,
    required this.childen,
  })  : builder = null,
        super(key: key);

  final Listenable listenable;

  final List<Widget>? childen;

  final Widget Function()? builder;

  final Widget Function(List<Widget> child)? childBuilder;

  @override
  State<StatefulWidget> createState() => _ListenBuilderState();
}

class _ListenBuilderState extends State<ListenBuilder>
    with SafeState<ListenBuilder> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_listener);
  }

  @override
  void didUpdateWidget(ListenBuilder oldWidget) {
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_listener);
      widget.listenable.addListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.childen == null) {
      return widget.builder?.call() ?? const SizedBox.shrink();
    }

    return widget.childBuilder?.call(widget.childen!) ??
        const SizedBox.shrink();
  }
}
