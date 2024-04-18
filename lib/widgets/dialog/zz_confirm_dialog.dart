import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';

import '../../resources/theme_colors.dart';
import '../zz_divider.dart';
import '../zz_ink_well.dart';


/// 通用确认对话框
///
/// @author 周卓
///
/// 顶部标题 + 中间消息 + 底部2个按钮
class ZzConfirmDialog extends AlertDialog {
  /// 标题
  final String? titleString;

  /// 消息
  final String msg;

  /// 消息对齐方式
  final TextAlign? msgTextAlign;

  /// 左边按钮文字，默认"取消"
  final String? leftBtnText;

  /// 左边按钮文字，默认"确定"
  final String? rightBtnText;

  /// 左边按钮回调
  final Function()? onLeftBtnTap;

  /// 右边按钮回调
  final Function()? onRightBtnTap;

  /// 标题文字颜色
  final Color? titleColor;

  /// 消息文字颜色
  final Color? msgColor;

  /// 左边按钮文字颜色
  final Color? leftBtnColor;

  /// 右边按钮文字颜色
  final Color? rightBtnColor;

  /// 标题文字大小
  final double? titleFontSize;

  /// 消息文字大小
  final double? msgFontSize;

  /// 按钮文字
  final double? btnFontSize;

  const ZzConfirmDialog(
      {Key? key,
      this.titleString,
      required this.msg,
      this.msgTextAlign,
      this.leftBtnText,
      this.rightBtnText,
      this.titleColor,
      this.leftBtnColor,
      this.rightBtnColor,
      this.msgColor,
      this.titleFontSize,
      this.msgFontSize,
      this.btnFontSize,
      this.onLeftBtnTap,
      this.onRightBtnTap})
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
      maxHeight: isLangScape ? 250.r : 500.r,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.r),
          padding: EdgeInsets.symmetric(horizontal: 8.r),
          child: Text(
            msg,
            textAlign: msgTextAlign ?? TextAlign.center,
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
            if (onLeftBtnTap != null) {
              onLeftBtnTap!();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 48.r,
            child: Text(
              leftBtnText ?? '取消',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: ThemeColors.text8C),
            ),
          ),
        )),
        ZzVerticalDivider(
          height: 48.r,
        ),
        Expanded(
            child: ZzInkWell(
          onTap: () {
            if (onRightBtnTap != null) {
              onRightBtnTap!();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 48.r,
            child: Text(
              rightBtnText ?? '确定',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: ThemeColors.textLightBlue),
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
