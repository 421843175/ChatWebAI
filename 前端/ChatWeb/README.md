# ChatWeb - 聊天电商平台

一个基于 Vue 2 + Element UI 的聊天与商品购物平台。

## 功能模块

### 商城模块
- 商品浏览（首页商品列表）
- 商品详情查看
- 商品分类筛选

### 聊天模块
- 实时在线聊天
- 好友管理
- 账号管理
- 聊天搜索

### 用户模块
- 登录/注册
- 个人设置
- 商品管理
- 问卷调查
- 评价管理

## 技术栈

- **前端框架**: Vue 2
- **UI 组件库**: Element UI
- **路由**: Vue Router
- **状态管理**: Vuex
- **网络请求**: Axios
- **加密**: CryptoJS
- **WebSocket**: Socket.io

## 项目结构

```
src/
├── components/          # 组件目录
│   ├── Chat/            # 聊天相关组件
│   ├── setting/          # 设置相关组件
│   ├── ChatWeb.vue       # 聊天主页面
│   ├── Clothes.vue       # 服装页面
│   ├── GoodsDetail.vue   # 商品详情
│   ├── Login.vue         # 登录页面
│   ├── Setting.vue       # 设置页面
│   └── shops.vue         # 商城首页
├── router/              # 路由配置
├── store/                # Vuex 状态管理
└── utils/                # 工具函数
```

## 页面路由

| 路径 | 页面 | 说明 |
|------|------|------|
| `/` | Shops | 商城首页 |
| `/goods/detail` | GoodsDetail | 商品详情 |
| `/login` | Login | 登录页面 |
| `/chat/:id` | ChatWeb | 聊天页面 |
| `/setting` | Setting | 个人设置 |

## 开发

```bash
# 安装依赖
npm install

# 开发模式运行
npm run dev

# 生产环境打包
npm run build

# 运行测试
npm test
```

## 环境要求

- Node.js >= 6.0.0
- npm >= 3.0.0
