/**
 * API配置类 - 管理所有后端API地址
 * 后端使用SpringBoot，接口地址保持一致
 */
class ApiConfig {
  // 后端服务器基础URL
  // 真机调试：使用电脑的实际IP地址（如 192.168.x.x）
  // 模拟器调试：使用 10.0.2.2 访问电脑的 localhost
  static const String baseURL = 'http://192.168.31.88:8090';

  // 用户相关接口
  static const String login = '$baseURL/user/login';           // 登录
  static const String register = '$baseURL/user/register';     // 注册

  // 聊天相关接口
  static const String getFriend = '$baseURL/chat/getFriend';    // 获取联系人列表
  static const String getMy = '$baseURL/chat/getMy';           // 获取当前用户信息
  static const String clearUnRead = '$baseURL/chat/clearUnRead'; // 清除未读
  static const String robot = '$baseURL/chat/robot';           // 机器人聊天
  static const String toArtificial = '$baseURL/chat/toArtificial'; // 转人工
  static const String toChatRobot = '$baseURL/chat/toChatRobot'; // 转机器人

  // 商品相关接口
  static const String goodsList = '$baseURL/goods/list';       // 商品列表
  static const String goodsDetail = '$baseURL/goods/detail';  // 商品详情
  static const String goodsSearch = '$baseURL/goods/search';  // 商品搜索
  static const String toChat = '$baseURL/goods/toChat';       // 联系商家

  // 评价相关接口
  static const String evaluateSubmit = '$baseURL/evaluate/submit';  // 提交评价

  // 模型相关接口
  static const String saveModel = '$baseURL/model/save';      // 保存模型
  static const String getModel = '$baseURL/model/getModel';    // 获取模型
}