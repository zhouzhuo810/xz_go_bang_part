import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../config/global.dart';
import '../widgets/dialog/zz_confirm_dialog.dart';
import '../widgets/dialog/zz_msg_dialog.dart';

bool msgDialogShowing = false;

/// 通用对话框，简化调用过程
class ZzDialog {
  ///消息对话框
  ///
  /// 顶部标题
  /// 中间内容
  /// 底部1个按钮-我知道了
  static showMsgDialog(
      {String? title,
      required String msg,
      TextAlign? msgTextAlign,
      String? btnText,
      bool barrierDismissible = true,
      GestureTapCallback? onBtnTap,
      Function()? onDismiss}) {
    msgDialogShowing = true;
    showDialog(
        context: Global.globalContext,
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (context) {
          return ZzMsgDialog(
            titleString: title,
            msg: msg,
            btnText: btnText ?? '我知道了',
            msgTextAlign: msgTextAlign,
            onBtnTap: () {
              Navigator.pop(context);
              onBtnTap?.call();
            },
          );
        }).then((value) {
      msgDialogShowing = false;
      onDismiss?.call();
    });
  }

  /// 确认对话框，
  ///
  /// 顶部标题
  /// 中间内容
  /// 底部两个按钮-取消和确定
  static showConfirmDialog(
      {String? title,
      required String msg,
      TextAlign? msgTextAlign,
      String? leftBtnText,
      String? rightBtnText,
      bool barrierDismissible = true,
      GestureTapCallback? onCancel,
      GestureTapCallback? onConfirm,
      Function()? onDismiss}) {
    showDialog(
        context: Global.globalContext,
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (context) {
          return ZzConfirmDialog(
            titleString: title,
            msg: msg,
            msgTextAlign: msgTextAlign,
            leftBtnText: leftBtnText,
            rightBtnText: rightBtnText,
            onLeftBtnTap: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            onRightBtnTap: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
          );
        }).then((value) => onDismiss?.call());
  }

  /// 显示loading
  static void showLoading({String? msg, bool showMask = false}) {
    EasyLoading.show(
        status: msg ?? '加载中...',
        maskType:
            showMask ? EasyLoadingMaskType.black : EasyLoadingMaskType.clear);
  }

  /// 关闭loading
  static void closeLoading() {
    EasyLoading.dismiss();
  }
}
