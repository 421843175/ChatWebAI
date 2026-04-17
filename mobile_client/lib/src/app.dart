import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'pages/login/login_page.dart';
import 'pages/home/home_page.dart';
import 'pages/chat/chat_page.dart';
import 'pages/setting/setting_page.dart';
import 'pages/goods/goods_detail_page.dart';

/**
 * 应用入口组件
 * 管理路由配置和全局样式
 */
class MobileUserApp extends StatelessWidget {
  const MobileUserApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 应用名称
      title: '人工智能客服系统',
      // 主题配置
      theme: AppTheme.lightTheme,
      // 路由配置
      initialRoute: '/login',
      onGenerateRoute: _generateRoute,
      // 调试模式关闭
      debugShowCheckedModeBanner: false,
    );
  }

  /**
   * 生成路由
   * 根据路由名称返回对应页面
   */
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // 根据路由名称匹配页面
    switch (settings.name) {
      case '/login':
        // 登录页面
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case '/home':
        // 主页（商品列表）
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case '/chat':
        // 聊天页面，传递参数
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatPage(
            user: args?['user'],
            role: args?['role'],
          ),
        );
      case '/setting':
        // 卖家设置页面
        return MaterialPageRoute(
          builder: (_) => const SettingPage(),
        );
      case '/goods-detail':
        // 商品详情页面
        final args = settings.arguments as Map<String, dynamic>?;
        final goodsId = args?['id'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => GoodsDetailPage(goodsId: goodsId),
        );
      default:
        // 默认跳转到登录页面
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }
}