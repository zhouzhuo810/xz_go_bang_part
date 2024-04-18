import 'package:get/get.dart';
import 'package:xz_go_bang_part/pages/home_page.dart';


class RouteMap {
  /// 路由配置
  static List<GetPage> getPages = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
    ),
  ];

}
