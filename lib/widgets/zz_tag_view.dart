import 'package:flutter/material.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';
import '../resources/theme_colors.dart';

/// 标签控件
///
/// 圆角边框 + 文字
///
/// @author 周卓
///
class ZzTagView extends StatelessWidget {
  /// 文字
  final String text;

  /// 字体大小，默认14
  final double? fontSize;

  /// 内边距
  final EdgeInsets? padding;

  /// 文字颜色，默认黄色
  final Color textColor;

  /// 边框颜色，默认黄色
  final Color borderColor;

  /// 背景颜色，默认透明
  final Color backgroundColor;

  /// 圆角，默认3
  final double? radius;

  /// 最大宽度，默认68
  final double? maxWidth;

  const ZzTagView(
      {Key? key,
      required this.text,
      this.padding,
      this.fontSize,
      this.maxWidth,
      this.textColor = ThemeColors.textYellow,
      this.borderColor = ThemeColors.textYellow,
      this.backgroundColor = ThemeColors.bgTransparent,
      this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 68.r),
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 3.5.r, vertical: 2.5.r),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 2.r)),
            border: Border.all(width: 0.5, color: borderColor)),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: fontSize ?? 12.sp, color: textColor),
        ),
      ),
    );
  }
}
