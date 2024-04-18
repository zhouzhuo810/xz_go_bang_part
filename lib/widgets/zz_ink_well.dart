import 'dart:math';

import 'package:flutter/material.dart';

/// 带水波纹的 InkWell
///
/// 支持设置水波纹的 圆角大小 和 四周padding
class ZzInkWell extends StatelessWidget {
  /// 点击事件
  final GestureTapCallback? onTap;

  /// 长按事件
  final GestureLongPressCallback? onLongPress;

  /// 是否圆形波纹
  final double radius;

  /// 水平左右padding，默认0，如果设置了[paddingLeft] 和 [paddingRight]，会优先使用这两者
  final double horizontalPadding;

  /// 垂直左右padding，默认0，如果设置了[paddingTop] 和 [paddingBottom]，会优先使用这两者
  final double verticalPadding;

  /// 左边padding
  final double? paddingLeft;

  /// 右边padding
  final double? paddingRight;

  /// 上边padding
  final double? paddingTop;

  /// 下边padding
  final double? paddingBottom;

  /// 背景颜色，默认透明，注意：设置padding后，会带上padding范围
  final Color backgroundColor;

  /// 边框颜色，默认无边框
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 点击后的颜色
  final Color? highlightColor;

  /// 是否使用水波纹，默认true
  final bool enableRipple;

  /// 子控件
  final Widget child;

  /// 功能提示
  final String? tooltip;

  /// 点击抬起事件，用于获取点击位置
  final GestureTapUpCallback? onTapUp;

  /// 鼠标右键
  final GestureTapUpCallback? onSecondaryTap;

  const ZzInkWell(
      {super.key,
      this.radius = 0,
      this.horizontalPadding = 0,
      this.verticalPadding = 0,
      this.borderWidth = 0,
      this.highlightColor,
      this.enableRipple = true,
      this.onTap,
      this.onTapUp,
      this.paddingLeft,
      this.paddingRight,
      this.paddingTop,
      this.paddingBottom,
      this.tooltip,
      this.onLongPress,
      this.onSecondaryTap,
      this.borderColor = Colors.transparent,
      this.backgroundColor = Colors.transparent,
      required this.child});

  @override
  Widget build(BuildContext context) {
    Widget widget = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            border: borderWidth == 0
                ? null
                : Border.all(
                    width: borderWidth,
                    color: borderColor == Colors.transparent
                        ? backgroundColor
                        : borderColor),
            color: backgroundColor),
        child: InkWell(
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPress: onLongPress,
          onSecondaryTapUp: onSecondaryTap,
          splashColor: enableRipple ? null : Colors.transparent,
          hoverColor: enableRipple ? null : Colors.transparent,
          highlightColor:
              highlightColor ?? (enableRipple ? null : Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: Padding(
            padding: EdgeInsets.only(
              left: max(0, (paddingLeft ?? horizontalPadding) - borderWidth),
              right: max(0, (paddingRight ?? horizontalPadding) - borderWidth),
              top: max(0, (paddingTop ?? verticalPadding) - borderWidth),
              bottom: max(0, (paddingBottom ?? verticalPadding) - borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: widget,
      );
    } else {
      return widget;
    }
  }
}
