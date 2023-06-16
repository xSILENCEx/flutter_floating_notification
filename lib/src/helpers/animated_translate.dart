import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedTranslate extends ImplicitlyAnimatedWidget {
  const AnimatedTranslate({
    Key? key,
    required this.child,
    required this.offset,
    super.curve = Curves.ease,
    super.duration = const Duration(milliseconds: 300),
    this.transformHitTests,
    this.filterQuality,
    super.onEnd,
  }) : super(key: key);

  final Widget child;
  final Offset offset;

  final bool? transformHitTests;
  final FilterQuality? filterQuality;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AppAnimatedPositionedState();
}

class _AppAnimatedPositionedState
    extends AnimatedWidgetBaseState<AnimatedTranslate> {
  Tween<Offset>? _offsetTween;

  @override
  Widget build(BuildContext context) {
    final Offset offset = _offsetTween?.evaluate(animation) ?? widget.offset;

    return Transform.translate(
      offset: offset,
      transformHitTests: widget.transformHitTests ?? true,
      filterQuality: widget.filterQuality,
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offsetTween = visitor(
      _offsetTween,
      widget.offset,
      (dynamic value) => Tween<Offset>(begin: value as Offset),
    ) as Tween<Offset>?;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Tween<Offset>>('offset', _offsetTween));
  }
}
