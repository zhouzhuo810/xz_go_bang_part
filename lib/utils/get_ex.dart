import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// [Get]扩展
extension GetEx on GetInterface {
  /// 查找通过Get.put(dependency)内容，未找到返回null
  S? findOrNull<S>({String? tag}) {
    if (!GetInstance().isRegistered<S>(tag: tag)) {
      return null;
    }

    try {
      return GetInstance().find<S>(tag: tag);
    } catch (e) {
      return null;
    }
  }

  /// 获取参数
  S? getArg<S>(String key) {
    var arg = arguments;
    if (arg == null) {
      return null;
    }

    if (arg is! Map) {
      return null;
    }

    return arg[key];
  }

  /// 获取通过路由路径携带的参数
  String? getParams(String key) {
    var route = Get.routing.route;
    if (route is GetPageRoute) {
      return route.parameter?[key];
    }
    return Get.parameters[key];
  }

  /// 从[Get.arguments]或[Get.parameters]取参数，优先从[Get.arguments]取值。
  /// 做了类型转换，为了兼容原生传值问题，
  /// 原生如果传值为bool，需要传"0"或"1"或"true"或"false"。
  /// 原生如果传值为复杂对象，需要使用[formJson]进行对象转换。
  T? getArgOrParams<T>(String key, {T? Function(String json)? formJson}) {
    var arg = getArg(key);
    String? params = getParams(key);
    if (arg != null) {
      return arg;
    } else if (params == null) {
      return null;
    } else if (T == bool) {
      return ((params == "1") || (params == "true")) as T;
    } else if (T == String) {
      return params as T;
    } else if (T == int) {
      return int.parse(params) as T;
    } else if (T == double) {
      return double.parse(params) as T;
    } else {
      return (formJson?.call(params) ?? params) as T;
    }
  }
}
