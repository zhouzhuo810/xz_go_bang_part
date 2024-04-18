import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';

import '../../resources/theme_colors.dart';
import '../zz_divider.dart';
import '../zz_ink_well.dart';

/// 通用消息对话框
///
/// @author 周卓
///
/// 顶部标题 + 中间消息 + 底部1个按钮
class ZzMsgDialog extends AlertDialog {
  /// 标题
  final String? titleString;

  /// 消息
  final String msg;

  /// 消息对齐方式
  final TextAlign? msgTextAlign;

  /// 按钮文字，默认"我知道了"
  final String? btnText;

  /// 按钮回调
  final Function()? onBtnTap;

  /// 标题文字颜色
  final Color? titleColor;

  /// 消息文字颜色
  final Color? msgColor;

  /// 按钮文字颜色
  final Color? btnColor;

  /// 标题文字大小
  final double? titleFontSize;

  /// 消息文字大小
  final double? msgFontSize;

  /// 按钮文字
  final double? btnFontSize;

  const ZzMsgDialog(
      {Key? key,
      this.titleString,
      required this.msg,
      this.msgTextAlign,
      this.btnText,
      this.titleColor,
      this.btnColor,
      this.msgColor,
      this.titleFontSize,
      this.msgFontSize,
      this.btnFontSize,
      this.onBtnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLangScape = context.orientation == Orientation.landscape;

    final List<Widget> children = <Widget>[];

    /// 上边距
    children.add(SizedBox(
      width: 1.r,
      height: 24.r,
    ));

    /// 标题
    if (titleString != null) {
      children.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        alignment: Alignment.center,
        child: Text(
          titleString!,
          style: TextStyle(
              fontSize: 16.sp,
              color: ThemeColors.text26,
              fontWeight: FontWeight.w600),
        ),
      ));
      children.add(SizedBox(
        width: 1.r,
        height: 16.r,
      ));
    }

    /// 消息
    children.add(LimitedBox(
      maxHeight: isLangScape ? 350.r : 500.r,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.r),
          padding: EdgeInsets.symmetric(horizontal: 8.r),
          alignment: msgTextAlign == null || msgTextAlign == TextAlign.center
              ? Alignment.center
              : msgTextAlign == TextAlign.right
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child: Text(
            msg,
            textAlign: msgTextAlign,
            style: TextStyle(fontSize: 16.sp, color: ThemeColors.text59),
          ),
        ),
      ),
    ));

    /// 下边距
    children.add(SizedBox(
      width: 1.r,
      height: 24.r,
    ));

    /// 底部按钮
    children.add(const ZzDivider());

    children.add(Row(
      children: [
        Expanded(
            child: ZzInkWell(
          onTap: () {
            if (onBtnTap != null) {
              onBtnTap!();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 48.r,
            child: Text(
              btnText ?? '确定',
              style: TextStyle(
                  fontSize: 16.sp,
                  color:
                      ThemeColors.textLightBlue),
            ),
          ),
        ))
      ],
    ));

    Widget dialogChild = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    return UnconstrainedBox(
        child: SizedBox(
            width: isLangScape ? 500.r : 320.r,
            child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.r))),
                color: ThemeColors.bgWhite,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                  child: dialogChild,
                ))));
  }
}
