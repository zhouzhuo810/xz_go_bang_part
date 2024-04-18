
import 'package:flutter/services.dart';

class Tools {

  /// 拼接字符串，中间使用[split]分割，如果有一个字符串为空，则不显示[split]
  static String concatString(String? str1, String? str2, String split) {
    if (str1 == null) {
      return str2 ?? '';
    }
    if (str2 == null) {
      return str1;
    }
    return '$str1$split$str2';
  }

  /// 复制字符串
  static void copyString(String text) async {
    ClipboardData data = ClipboardData(text: text);
    await Clipboard.setData(data);
  }

  /// 获取剪切板文字
  static Future<String?> getClipData() async {
    var data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// 时间戳
  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 时间戳
  static int nanoTime() {
    return DateTime.now().microsecondsSinceEpoch;
  }

}
