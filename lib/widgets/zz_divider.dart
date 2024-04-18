import 'package:flutter/material.dart';

import '../resources/theme_colors.dart';


/// 通用水平分割线
///
/// @author 周卓
///
class ZzDivider extends StatelessWidget {
  /// 分割线高度
  final double height;

  /// 分割线宽度
  final double width;

  /// 分割线颜色
  final Color? color;

  /// 左边margin
  final double leftMargin;

  /// 右侧margin
  final double rightMargin;

  const ZzDivider(
      {Key? key,
      this.width = double.infinity,
      this.height = 0.5,
      this.color,
      this.leftMargin = 0,
      this.rightMargin = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
      width: width,
      height: height,
      color: color ?? ThemeColors.lineColorLight,
    );
  }
}

/// 垂直分割线
class ZzVerticalDivider extends StatelessWidget {
  /// 宽度
  final double width;

  /// 高度
  final double height;

  /// 分割线颜色
  final Color? color;

  /// 左边margin
  final double topMargin;

  /// 右侧margin
  final double bottomMargin;

  const ZzVerticalDivider(
      {Key? key,
      this.width = 0.5,
      this.height = double.infinity,
      this.color,
      this.topMargin = 0,
      this.bottomMargin = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color ?? ThemeColors.lineColorLight,
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
    );
  }
}
