
import 'package:flutter/foundation.dart';

/// 日志工具
class Log {
  Log._();

  /// 是否启用日志
  static bool enable = !kReleaseMode;

  /// 打印日志级别
  static LogLevel logLevel = LogLevel.debug;

  /// 全局日志标签
  static String tag = "Log";

  /// 打印DEBUG级别日志
  static void d(Object msg, {String? tag}) {
    _printLog(LogLevel.debug, tag, msg, enable);
  }

  /// 打印INFO级别日志
  static void i(Object msg, {String? tag}) {
    _printLog(LogLevel.info, tag, msg, enable);
  }

  /// 打印WARRING级别日志
  static void w(Object msg, {String? tag}) {
    _printLog(LogLevel.warring, tag, msg, enable);
  }

  /// 打印ERROR级别日志
  static void e(Object msg, {String? tag}) {
    _printLog(LogLevel.error, tag, msg, enable);
  }

  static void _printLog(
      LogLevel level, String? tag, Object msg, bool canPrint) {
    if (canPrint && level.index >= logLevel.index) {
      String flag;
      switch (level) {
        case LogLevel.debug:
          flag = "D/";
          break;
        case LogLevel.info:
          flag = "I/";
          break;
        case LogLevel.warring:
          flag = "W/";
          break;
        case LogLevel.error:
          flag = "E/";
          break;
      }

      // 此日志打印，会将信息打印到Android LogCat控制台
      // ignore: avoid_print
      print("$flag${tag ?? Log.tag}:$msg");

      // 'dart:developer'库中定义的日志打印，在android平台，会将信息打印到Flutter调试控制台
      // log(msg.toString(), name: "$flag${tag ?? Log.tag}", level: level.level);
    }
  }
}

/// 日志级别
enum LogLevel {
  debug(0),
  info(1),
  warring(2),
  error(3);

  final int level;

  const LogLevel(this.level);
}
