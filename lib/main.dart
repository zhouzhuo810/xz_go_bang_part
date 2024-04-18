import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:xz_go_bang_part/utils/kq_screen_util.dart';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'config/global.dart';
import 'router/route_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Global.init().then((value) => runMPApp(const MyApp()));
}

/// 程序入口
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KqScreenUtilInit(
      //初始化屏幕适配框架
      designSize: const Size(414, 736),
      minTextAdapt: true,
      builder: _buildApp,
      disableScale: (data) {
        // 宽设备不缩放
        return data.size.width > 600;
      },
    );
  }

  void _initWithContext(BuildContext context) {
    // 隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  Widget _buildApp(BuildContext context, Widget? child) {
    return GetMaterialApp(
      title: '小周五子棋',
      navigatorKey: Global.navigatorKey,
      getPages: RouteMap.getPages,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
      navigatorObservers: [PageRouteObserver._pageRouteObserver._routeObserver],
      //配置错误的情况，使用的语言
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: child,
      builder: (context, child) {
        _initWithContext(context);
        return EasyLoading.init()(context, child);
      },
    );
  }
}

/// 页面路由监听
///
/// 可监听当前界面显示还是隐藏，从导航加载及移出导航
class PageRouteObserver {
  /// 路由监听器
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  static final PageRouteObserver _pageRouteObserver =
      PageRouteObserver._internal();

  PageRouteObserver._internal();

  /// 注册页面路由监听
  ///
  /// [context]为页面上下文，通过此上下文找到当前页面路由，如果无法找到，则不会注册。
  /// 而且只支持页面路由的注册，弹窗类路由不支持
  static void subscribe(RouteAware routeAware, BuildContext context) {
    var route = ModalRoute.of(context);
    if (route is PageRoute) {
      _pageRouteObserver._routeObserver.subscribe(routeAware, route);
    }
  }

  /// 移除页面路由监听
  static void unsubscribe(RouteAware routeAware) {
    _pageRouteObserver._routeObserver.unsubscribe(routeAware);
  }
}
