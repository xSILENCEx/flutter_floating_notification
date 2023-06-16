import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flush_bar/src/helpers/animated_translate.dart';
import 'package:flutter_flush_bar/src/helpers/ex_value.dart';
import 'package:flutter_flush_bar/src/helpers/get_size.dart';

import 'flush_functions.dart';

class _FlushValue {
  const _FlushValue(this.offset, this.duration);

  const _FlushValue.initial()
      : offset = const Offset(0, -100000),
        duration = Duration.zero;

  final Offset offset;
  final Duration duration;

  _FlushValue copyWith({Offset? offset, Duration? duration}) {
    return _FlushValue(offset ?? this.offset, duration ?? this.duration);
  }
}

class _FlushProvider extends ExValue<_FlushValue> {
  _FlushProvider() : super(const _FlushValue.initial());

  Offset get offset => value.offset;

  void updateOffset(Offset offset, {bool withGesture = false}) {
    value = value.copyWith(
        offset: offset, duration: withGesture ? Duration.zero : null);
  }

  void updateDuration(Duration duration) {
    value = value.copyWith(duration: duration);
  }
}

class FlushBarContent<T> extends StatefulWidget {
  const FlushBarContent({
    super.key,
    required this.childBuilder,
    this.duration = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.ease,
    required this.onDismissed,
    this.onTap,
    this.height,
  });

  final FlushContentBuilder<T> childBuilder;
  final Duration duration;
  final Duration animationDuration;
  final Curve animationCurve;
  final Function(T? value) onDismissed;
  final OnFlushTap<T>? onTap;
  final double? height;

  @override
  State<FlushBarContent<T>> createState() => _FlushBarContentState<T>();
}

class _FlushBarContentState<T> extends State<FlushBarContent<T>> {
  final _FlushProvider _flushProvider = _FlushProvider();

  late double _height = widget.height ?? 80;

  Timer? _timer;

  bool _locked = false;

  double get sw => MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stopTimer();
    _flushProvider.dispose();
    super.dispose();
  }

  void _startTimer({Duration? additional}) {
    _timer ??= Timer(widget.duration + (additional ?? Duration.zero), _dismiss);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _show() async {
    _flushProvider.updateDuration(widget.animationDuration);
    _flushProvider.updateOffset(Offset.zero);
    _startTimer(additional: widget.animationDuration);
  }

  Future<void> _dismiss({Offset? offset, Duration? duration, T? value}) async {
    if (_locked) return;

    _flushProvider.updateDuration(duration ?? widget.animationDuration);
    _flushProvider.updateOffset(offset ?? Offset(0, -_height));
    _locked = true;
    await Future<void>.delayed(duration ?? widget.animationDuration);
    widget.onDismissed(value);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (_flushProvider.offset.dx != 0 || _locked) {
      return;
    }

    _stopTimer();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_flushProvider.offset.dx != 0 || _locked) {
      return;
    }

    if (details.delta.dy > 0 && _flushProvider.offset.dy >= 0) {
      return;
    }

    _flushProvider.updateOffset(
        Offset(0, _flushProvider.offset.dy + details.delta.dy),
        withGesture: true);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_flushProvider.offset.dx != 0 || _locked) {
      return;
    }

    // 超出屏幕的比例
    final double value = -_flushProvider.offset.dy / _height;
    final bool isFast = details.velocity.pixelsPerSecond.dy < -500;

    Duration duration = widget.animationDuration * value;
    if (duration <= Duration.zero) {
      duration = const Duration(milliseconds: 50);
    }

    if (value > 0.5 || isFast) {
      duration = const Duration(milliseconds: 200);
      _dismiss(duration: duration);
    } else {
      _flushProvider.updateDuration(duration);
      _flushProvider.updateOffset(Offset.zero);
      _startTimer();
    }
  }

  void _onVerticalDragCancel() {
    if (_flushProvider.offset.dx != 0 || _locked) {
      return;
    }

    // 超出屏幕的比例
    final double value = -_flushProvider.offset.dy / _height;

    Duration duration = widget.animationDuration * value;
    if (duration <= Duration.zero) {
      duration = const Duration(milliseconds: 50);
    }

    if (value > 0.5) {
      _dismiss(duration: duration);
    } else {
      _flushProvider.updateDuration(duration);
      _flushProvider.updateOffset(Offset.zero);
      _startTimer();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_flushProvider.offset.dy != 0 || _locked) {
      return;
    }

    _stopTimer();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_flushProvider.offset.dy != 0 || _locked) {
      return;
    }

    _flushProvider.updateOffset(
        Offset(_flushProvider.offset.dx + details.delta.dx, 0),
        withGesture: true);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_flushProvider.offset.dy != 0 || _locked) {
      return;
    }

    // 超出屏幕的比例
    final double value = _flushProvider.offset.dx / sw;

    Duration duration = widget.animationDuration * value.abs();
    if (duration <= Duration.zero) {
      duration = const Duration(milliseconds: 50);
    }

    final bool isFastToLeft = details.velocity.pixelsPerSecond.dx < -500;
    final bool isFastToRight = details.velocity.pixelsPerSecond.dx > 500;

    if (isFastToLeft) {
      _dismiss(
          offset: Offset(-sw, 0), duration: const Duration(milliseconds: 200));
    } else if (isFastToRight) {
      _dismiss(
          offset: Offset(sw, 0), duration: const Duration(milliseconds: 200));
    } else if (value < -0.5) {
      _dismiss(offset: Offset(-sw, 0), duration: duration);
    } else if (value > 0.5) {
      _dismiss(offset: Offset(sw, 0), duration: duration);
    } else {
      _flushProvider.updateDuration(duration);
      _flushProvider.updateOffset(Offset.zero);
      _startTimer();
    }
  }

  void _onHorizontalDragCancel() {
    if (_flushProvider.offset.dy != 0 || _locked) {
      return;
    }

    // 超出屏幕的比例
    final double value = _flushProvider.offset.dx / sw;

    Duration duration = widget.animationDuration * value.abs();
    if (duration <= Duration.zero) {
      duration = const Duration(milliseconds: 50);
    }

    if (value < -0.5) {
      _dismiss(offset: Offset(-sw, 0), duration: duration);
    } else if (value > 0.5) {
      _dismiss(offset: Offset(sw, 0), duration: duration);
    } else {
      _flushProvider.updateDuration(duration);
      _flushProvider.updateOffset(Offset.zero);
      _startTimer();
    }
  }

  void _onTap() {
    widget.onTap?.call(_dismiss);
  }

  Future<void> _sizeChanged(Size s) async {
    _height = s.height;
    _flushProvider.updateOffset(Offset(0, -_height), withGesture: true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _show();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: sw,
        height: widget.height,
        child: _flushProvider.buildWithChild(
          (_FlushValue v, Widget c) {
            return AnimatedTranslate(
              duration: v.duration,
              curve: widget.animationCurve,
              offset: v.offset,
              child: c,
            );
          },
          child: GestureDetector(
            onTap: _onTap,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            onVerticalDragCancel: _onVerticalDragCancel,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onHorizontalDragCancel: _onHorizontalDragCancel,
            child: Material(
              color: Colors.transparent,
              child: GetSize(
                onChanged: _sizeChanged,
                child: widget.childBuilder(context, _dismiss),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
