import 'package:flutter/material.dart';

import 'flush_bar_content.dart';
import 'flush_functions.dart';

class FlutterFlushBar {
  FlutterFlushBar();

  static final FlutterFlushBar instance = FlutterFlushBar();

  final List<OverlayEntry> _flushEntryList = <OverlayEntry>[];

  bool _isFlushShowing = false;

  void _overlayInsert(BuildContext context, OverlayEntry entry) {
    try {
      Overlay.of(context).insert(entry);
    } catch (e) {
      debugPrint('_overlayInsert error: $e');
    }
  }

  void showFlushBar<T>(
    BuildContext context, {
    required FlushContentBuilder<T> childBuilder,
    Duration? animationDuration,
    Curve? animationCurve,
    Duration? duration,
    double? height,
    Function(T? value)? onDismiss,
    OnFlushTap<T>? onTap,
  }) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (BuildContext context) => FlushBarContent<T>(
        childBuilder: childBuilder,
        duration: duration ?? const Duration(seconds: 2),
        animationDuration: animationDuration ?? const Duration(milliseconds: 500),
        animationCurve: animationCurve ?? Curves.ease,
        height: height,
        onTap: onTap,
        onDismiss: (T? value) {
          onDismiss?.call(value);
          _showFlushComplete(context);
        },
      ),
    );

    _flushEntryList.add(entry);

    if (!_isFlushShowing) {
      _show(context, _flushEntryList.first);
    }
  }

  void _show(BuildContext context, OverlayEntry entry) {
    _isFlushShowing = true;
    Future<void>.microtask(() => _overlayInsert(context, entry));
  }

  void _showFlushComplete(BuildContext context) {
    if (_flushEntryList.isNotEmpty) {
      _flushEntryList.first.remove();
      _flushEntryList.removeAt(0);
    }

    if (_flushEntryList.isEmpty) {
      _isFlushShowing = false;
    } else {
      _show(context, _flushEntryList.first);
    }
  }

  void clear() {
    for (final OverlayEntry entry in _flushEntryList) {
      entry.remove();
    }
    _isFlushShowing = false;
    _flushEntryList.clear();
  }
}
