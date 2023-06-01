import 'dart:async';

import 'package:flutter/material.dart';

/// State安全扩展
mixin SafeState<T extends StatefulWidget> on State<T> {
  /// 安全刷新
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    if (mounted) {
      await fn();
      setState(fn);
    }
  }

  @override
  void setState(Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
