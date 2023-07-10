import 'package:flutter/material.dart';

/// 浮动通知组件关闭回调
typedef FlushDismiss<T> = Future<void> Function(
    {Offset? offset, Duration? duration, T? value});

/// 浮动通知组件构建器
typedef FlushContentBuilder<T> = Widget Function(
    BuildContext context, FlushDismiss<T> dismiss);

/// 浮动通知组件点击回调
typedef OnFlushTap<T> = void Function(FlushDismiss<T> dismiss);
