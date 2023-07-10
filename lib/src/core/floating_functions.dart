import 'package:flutter/material.dart';

typedef FlushDismiss<T> = Future<void> Function(
    {Offset? offset, Duration? duration, T? value});

typedef FlushContentBuilder<T> = Widget Function(
    BuildContext context, FlushDismiss<T> dismiss);

typedef OnFlushTap<T> = void Function(FlushDismiss<T> dismiss);
