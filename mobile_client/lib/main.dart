import 'package:flutter/material.dart';
// 导入应用主组件
import 'src/app.dart';

// 程序入口函数
void main() {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 运行应用
  runApp(const MobileUserApp());
}