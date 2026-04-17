# ChatWeb 手机用户端

这是一个面向普通用户的 Flutter 手机端，直接复用当前项目里的 SpringBoot 接口：

- 登录/注册：`/user/login`、`/user/register`
- 商品浏览/发起咨询：`/goods/list`、`/goods/toChat`
- 会话列表/历史消息：`/chat/getFriend`、`/chat/getHistory`
- 机器人/人工切换：`/chat/robot`、`/chat/toArtificial`
- 用户资料/头像上传：`/user/update`、`/upload/avatar`
- 评价提交：`/evaluate/submit`

## 已实现的页面

- 登录/注册
- 商品首页
- 商品详情
- 会话列表
- 聊天页面
- 我的页面
- 资料编辑
- 服务器地址设置

## 运行说明

当前目录里已经写好了 Flutter 代码，但这台机器上没有 Flutter SDK，所以我没有办法在本地把 `android`、`ios` 原生工程也生成出来。

安装 Flutter 后，建议在这个目录执行：

```bash
flutter create .
flutter pub get
flutter run
```

## 后端地址说明

默认地址：

- HTTP: `http://10.0.2.2:8090`
- WebSocket: `ws://10.0.2.2:8091/socket.io`

这是为了优先兼容 Android 模拟器。

如果你用真机调试，请在“我的 -> 服务器地址”里把地址改成你电脑在局域网里的 IP，例如：

```text
http://192.168.1.20:8090
ws://192.168.1.20:8091/socket.io
```

也可以在启动时通过 `dart-define` 覆盖：

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8090 --dart-define=WS_BASE_URL=ws://192.168.1.20:8091/socket.io
```

## 额外说明

Web 前端里密码加密常量并没有完整暴露在 `constant.js` 中，所以这个手机端当前直接按后端现有接口字段提交密码文本。如果后续你准备统一密码加密逻辑，建议把前端和移动端共用的 AES key 抽到明确配置里。

