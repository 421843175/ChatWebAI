# ChatWeb 智能客服聊天系统

<!-- 徽章 -->
<div align="center">

![Java](https://img.shields.io/badge/Java-17+-blue.svg)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.6-green.svg)
![Vue.js](https://img.shields.io/badge/Vue.js-2.x-brightgreen.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.3+-purple.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)
![Redis](https://img.shields.io/badge/Redis-6.0-red.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

**基于 Spring Boot + Vue.js + Flutter 的智能客服聊天系统**

支持 AI 自动回复、WebSocket 实时通信、Docker 一键部署

[功能介绍](#功能特性) • [快速开始](#快速开始) • [部署指南](#docker-compose-部署) • [项目结构](#项目结构) • [API 文档](#api-文档)

</div>

---

## 项目简介

ChatWeb 是一款面向企业的智能客服聊天系统，采用前后端分离架构，后端基于 Spring Boot 构建，前端同时提供 Web（Vue.js）和移动端（Flutter）两套客户端。

系统集成 DeepSeek AI API，能够自动处理客户咨询，支持 AI 模式与人工模式切换，显著提升客服效率。

### 核心特性

- **AI 智能客服** - 基于 DeepSeek API 的智能对话，自动理解用户意图
- **实时通信** - WebSocket 实现消息实时推送，支持多端同步
- **用户认证** - JWT Token 无状态认证，支持登录注册
- **会话管理** - 支持 AI 模式与人工客服模式灵活切换
- **跨平台支持** - 同时提供 Web 和移动端（Android/iOS）客户端
- **容器化部署** - Docker Compose 一键部署，支持水平扩展

---

## 系统架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              用户层                                      │
├───────────────────────┬───────────────────────┬─────────────────────────┤
│   Web 客户端 (Vue.js)  │   移动端 (Flutter)     │     第三方调用           │
│   http://localhost:8081│   Android / iOS       │     HTTP REST API       │
└───────────────────────┴───────────────────────┴─────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Nginx 负载均衡                                │
│                         端口：8081 (HTTP)                               │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│      Spring Boot 后端 (HTTP)     │   │    Spring Boot 后端 (WebSocket)   │
│         端口：8090               │   │         端口：8091                │
└─────────────────────────────────┘   └─────────────────────────────────┘
                    │                               │
                    └───────────────┬───────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              数据层                                      │
├─────────────────────────────────┬───────────────────────────────────────┤
│            MySQL 8.0            │              Redis 6.0                 │
│         端口：3306               │             端口：6379                 │
│         数据持久化               │         缓存 / 会话存储 / AI 记忆      │
└─────────────────────────────────┴───────────────────────────────────────┘
```

### 技术栈详情

| 组件 | 技术 | 版本 | 用途 |
|------|------|------|------|
| **后端框架** | Spring Boot | 2.6.x | RESTful API、WebSocket 服务 |
| **ORM 框架** | MyBatis Plus | 3.3.x | 数据库访问层 |
| **安全框架** | Apache Shiro | 1.6.x | 用户认证、权限管理 |
| **令牌方案** | JWT | 3.5.x | 无状态身份验证 |
| **Web 容器** | Netty | 4.1.x | WebSocket 长连接通信 |
| **AI 集成** | DeepSeek API | - | 智能对话能力 |
| **分词库** | HanLP | 1.8.x | 中文语义分析 |
| **文档生成** | Swagger | 2.9.x | API 接口文档 |
| **Web 前端** | Vue.js | 2.x | 响应式聊天界面 |
| **移动端** | Flutter | 3.3.x | 跨平台移动应用 |
| **数据库** | MySQL | 8.0.x | 关系型数据存储 |
| **缓存** | Redis | 6.x | 会话缓存、AI 对话记忆 |
| **Web 服务器** | Nginx | - | 负载均衡、静态资源服务 |
| **容器化** | Docker Compose | - | 一键部署、编排 |

---

## 功能特性

### 用户端功能

| 功能 | Web | 移动端 | 说明 |
|------|:---:|:------:|------|
| 用户登录/注册 | ✅ | ✅ | JWT Token 认证 |
| 发送文字消息 | ✅ | ✅ | 实时推送 |
| 发送图片 | ✅ | ✅ | 文件上传支持 |
| AI 智能回复 | ✅ | ✅ | DeepSeek API 驱动 |
| 人工客服切换 | ✅ | ✅ | AI/人工模式切换 |
| 未读消息提醒 | ✅ | ✅ | 红点提示 |
| 历史消息查看 | ✅ | ✅ | 分页加载 |
| 会话列表管理 | ✅ | ✅ | 消息预览 |

### 管理功能（预留）

| 功能 | 说明 |
|------|------|
| 用户管理 | 用户信息维护 |
| 客服分配 | 会话分配给人工客服 |
| 聊天记录 | 完整对话存档 |
| 数据统计 | 访问量、回复率统计 |

---

## 快速开始

### 环境要求

| 组件 | 最低版本 | 推荐版本 |
|------|----------|----------|
| JDK | 17 | 17 LTS |
| Node.js | 16 | 18 LTS |
| npm | 8 | 9+ |
| Flutter | 3.3 | 3.10+ |
| MySQL | 8.0 | 8.0.30+ |
| Redis | 6.0 | 6.2+ |
| Docker | 20.10 | 24+ |
| Docker Compose | 2.0 | 2.20+ |

### 方式一：本地开发

#### 1. 环境准备

```bash
# 克隆项目
git clone https://github.com/your-username/ChatWeb.git
cd ChatWeb
```

#### 2. 启动数据库

```bash
# 使用 Docker 启动 MySQL 和 Redis
docker run -d \
  --name chatweb-mysql \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -e MYSQL_DATABASE=chatweb \
  -p 3306:3306 \
  mysql:8

docker run -d \
  --name chatweb-redis \
  -p 6379:6379 \
  redis:alpine
```

#### 3. 初始化数据库

```bash
# 导入数据库脚本
mysql -u root -p chatweb < 数据库/chatweb.sql
```

#### 4. 配置后端

编辑 `backend/ChatWEBAI/src/main/resources/application-dev.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/chatweb?serverTimezone=UTC
    username: root
    password: your_password
  redis:
    host: localhost
    port: 6379
    password: your_redis_password

deepseek:
  api-key: your_deepseek_api_key
  base-url: https://api.deepseek.com
  model: deepseek-chat
```

#### 5. 启动后端

```bash
cd backend/ChatWEBAI

# 使用 Maven 启动
mvn spring-boot:run

# 或打包后运行
mvn clean package -DskipTests
java -jar target/CHATWEB-0.0.1-SNAPSHOT.jar
```

后端服务端口：
- HTTP API：`http://localhost:8090`
- WebSocket：`ws://localhost:8091`
- Swagger 文档：`http://localhost:8090/swagger-ui.html`

#### 6. 启动前端

```bash
cd 前端/ChatWeb

# 安装依赖
npm install

# 开发环境启动
npm run serve

# 访问 http://localhost:8081
```

#### 7. 启动 Flutter 移动端

```bash
cd mobile_client

# 获取依赖
flutter pub get

# 运行（需连接真机或模拟器）
flutter run

# 构建 APK
flutter build apk --release
```

### 方式二：Docker 一键部署

```bash
cd myjavadockertest

# 首次启动（包含构建）
docker-compose up -d --build

# 查看服务状态
docker-compose ps

# 查看后端日志
docker-compose logs -f backend

# 停止服务
docker-compose down
```

**访问地址：**

| 服务 | 地址 |
|------|------|
| Web 前端 | http://localhost:8081 |
| Swagger API 文档 | http://localhost:8090/swagger-ui.html |

---

## 项目结构

```
ChatWeb/
├── README.md                 # 项目说明文档
├── 数据库/
│   └── chatweb.sql           # 数据库初始化脚本（完整表结构 + 初始数据）
│
├── 前端/                      # Vue.js Web 前端
│   └── ChatWeb/
│       ├── src/              # Vue 组件源码
│       │   ├── components/   # 页面组件
│       │   ├── views/        # 路由视图
│       │   ├── store/        # Vuex 状态管理
│       │   ├── router/       # 路由配置
│       │   └── utils/        # 工具函数
│       ├── package.json      # 前端依赖
│       └── dist/             # 构建产物
│
├── backend/                   # Spring Boot 后端
│   └── ChatWEBAI/
│       ├── src/main/java/    # Java 源码
│       │   └── com.jupiter/   # 主包
│       │       ├── controller/   # REST 控制器
│       │       ├── websocket/    # WebSocket 处理
│       │       ├── service/      # 业务逻辑
│       │       ├── mapper/        # 数据访问层
│       │       ├── entity/        # 实体类
│       │       ├── config/        # 配置类
│       │       └── utils/         # 工具类
│       ├── src/main/resources/
│       │   ├── application.yml    # 主配置
│       │   └── application-dev.yml # 开发环境配置
│       └── pom.xml               # Maven 依赖
│
├── mobile_client/             # Flutter 移动端
│   └── lib/
│       ├── main.dart         # 应用入口
│       ├── pages/            # 页面
│       ├── widgets/          # 组件
│       ├── services/        # API 服务
│       ├── models/           # 数据模型
│       └── utils/            # 工具类
│
└── myjavadockertest/          # Docker 部署配置
    ├── docker-compose.yml    # 容器编排配置
    ├── backend/               # 后端容器配置
    │   └── Dockerfile
    ├── frontend/              # 前端容器配置
    │   ├── Dockerfile
    │   └── nginx.conf         # Nginx 配置
    └── mysql/                  # MySQL 初始化脚本
        └── init/
            └── chatweb.sql
```

---

## API 文档

### 认证接口

| 方法 | 路径 | 说明 | 参数 |
|------|------|------|------|
| POST | `/api/user/login` | 用户登录 | `{username, password}` |
| POST | `/api/user/register` | 用户注册 | `{username, password, email}` |
| GET | `/api/user/info` | 获取用户信息 | Header: Authorization |

### 会话接口

| 方法 | 路径 | 说明 | 参数 |
|------|------|------|------|
| GET | `/api/session/list` | 获取会话列表 | - |
| POST | `/api/session/create` | 创建会话 | `{userId, aiFlag}` |
| DELETE | `/api/session/{id}` | 删除会话 | - |
| PUT | `/api/session/{id}/mode` | 切换会话模式 | `{mode: "AI"/"HUMAN"}` |

### 消息接口

| 方法 | 路径 | 说明 | 参数 |
|------|------|------|------|
| GET | `/api/message/list` | 获取消息历史 | `?sessionId=&page=&size=` |
| POST | `/api/message/send` | 发送消息 | `{sessionId, content, type}` |
| POST | `/api/message/image` | 上传图片 | multipart/form-data |

### WebSocket 消息协议

**连接建立：**
```
ws://localhost:8091/socket.io/?token=xxx&EIO=4&transport=websocket
```

**发送消息格式：**
```json
{
  "type": "MSG",
  "data": {
    "sessionId": "会话ID",
    "content": "消息内容",
    "messageType": "TEXT"
  }
}
```

**接收消息格式：**
```json
{
  "type": "message",
  "data": {
    "from": "user/ai/server",
    "content": "消息内容",
    "timestamp": 1234567890
  }
}
```

详细 API 文档请访问 Swagger UI：`http://localhost:8090/swagger-ui.html`

---

## WebSocket 多实例支持

系统支持 Docker Compose 部署多个后端实例，通过 Redis Pub/Sub 实现 WebSocket 消息同步。

### 实现机制

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Backend-1   │     │  Backend-2   │     │  Backend-3   │
│  (实例1)     │     │  (实例2)     │     │  (实例3)     │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │  publishMessage() │                   │
       └──────────────────┼───────────────────┘
                          ▼
              ┌───────────────────────┐
              │    Redis Pub/Sub      │
              │  websocket:message    │
              └───────────────────────┘
                          │
       ┌──────────────────┼──────────────────┐
       ▼                  ▼                  ▼
  检查目标用户        检查目标用户        检查目标用户
  是否在本地          是否在本地          是否在本地
  是则发送            是则发送            是则发送
```

### 核心组件

| 组件 | 作用 |
|------|------|
| `ChannelService` | 管理用户与 Channel 的映射关系，存储到 Redis Hash |
| `RedisPubSubService` | 消息发布到 `websocket:message` 频道 |
| `RedisConfig` | 配置 `RedisMessageListenerContainer` 订阅消息频道 |
| `MessagesHandler` | 处理 WebSocket 消息，通过 Pub/Sub 广播 |

### 消息流程

1. **用户连接时** - `ChannelService.bindUser()` 将 `username -> instanceId:channelId` 存入 Redis Hash
2. **发送消息时** - `MessagesHandler` 调用 `RedisPubSubService.publishMessage()` 发布消息
3. **消息路由** - 所有实例收到消息后，检查目标用户是否在本地缓存，只有在本地才通过 Channel 发送
4. **离线消息** - 如果目标用户离线，消息持久化到数据库，更新未读计数

### 水平扩展

可以随时通过修改 `docker-compose.yml` 中的 `replicas` 数量来扩展后端实例：

```yaml
backend:
  deploy:
    replicas: 5   # 扩展到 5 个实例
```

---

## 配置文件说明

### 后端配置 (application-dev.yml)

```yaml
server:
  port: 8090                    # HTTP API 端口
  websocket:
    port: 8091                  # WebSocket 端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/chatweb
    username: root
    password: your_password
  redis:
    host: localhost
    port: 6379
    password: your_redis_password
    database: 0

reply:
  min-match-score: 0.3           # 相似度阈值

deepseek:
  api-key: your_api_key          # DeepSeek API 密钥
  base-url: https://api.deepseek.com
  model: deepseek-chat

file:
  upload-dir: ./uploads         # 文件上传目录
```

### Nginx 配置 (nginx.conf)

```nginx
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        least_conn;
        server backend:8090;
    }

    upstream ws_backend {
        server backend:8091;
    }

    server {
        listen 80;

        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /socket.io/ {
            proxy_pass http://ws_backend/socket.io/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 86400;
        }
    }
}
```

---

## 数据库表结构

### 用户表 (user)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| username | VARCHAR(50) | 用户名 |
| password | VARCHAR(100) | 密码（加密存储） |
| email | VARCHAR(100) | 邮箱 |
| create_time | DATETIME | 创建时间 |

### 会话表 (session)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| user_id | BIGINT | 用户ID |
| ai_flag | TINYINT | 0=人工模式, 1=AI模式 |
| create_time | DATETIME | 创建时间 |

### 消息表 (message)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| session_id | BIGINT | 会话ID |
| from_id | BIGINT | 发送者ID |
| content | TEXT | 消息内容 |
| message_type | VARCHAR(20) | 消息类型 |
| create_time | DATETIME | 创建时间 |

---

## 常见问题

### Q: 启动后端报数据库连接错误？

确保 MySQL 已启动且配置正确：
```bash
# 检查 MySQL 容器
docker ps | grep mysql

# 测试连接
mysql -h localhost -u root -p -e "SELECT 1"
```

### Q: AI 回复显示 "API 密钥无效"？

检查 `application-dev.yml` 中的 `deepseek.api-key` 配置，确保使用了有效的 DeepSeek API 密钥。

### Q: WebSocket 连接失败？

1. 检查后端 WebSocket 端口（8091）是否正常
2. 检查 Nginx 配置中的 WebSocket 代理设置
3. 确保防火墙允许相应端口访问

### Q: Docker 部署后前端无法访问？

```bash
# 检查容器状态
docker-compose ps

# 检查 Nginx 日志
docker-compose logs frontend

# 重新构建
docker-compose up -d --build frontend
```

---

## 开发指南

### 添加新的 API 接口

1. 在 `controller` 包下创建新的 Controller 类
2. 使用 `@RestController` 和 `@RequestMapping` 注解
3. 添加 Swagger 注解 `@ApiOperation` 描述接口
4. 在 Service 层实现业务逻辑

示例：
```java
@ApiOperation("获取用户列表")
@GetMapping("/list")
public Result<List<User>> list() {
    return Result.success(userService.list());
}
```

### 添加新的 WebSocket 消息类型

1. 在消息实体中添加新的 type 常量
2. 在 WebSocket Handler 中处理新的消息类型
3. 前端对应添加消息处理逻辑

---

## 许可证

本项目基于 [MIT License](LICENSE) 开源，欢迎贡献代码。

---

## 致谢

- [Spring Boot](https://spring.io/projects/spring-boot) - 后端框架
- [Vue.js](https://vuejs.org/) - 前端框架
- [Flutter](https://flutter.dev/) - 跨平台框架
- [Element UI](https://element.eleme.cn/) - UI 组件库
- [MyBatis Plus](https://baomidou.com/) - ORM 框架
- [DeepSeek](https://deepseek.com/) - AI 能力支持
- [HanLP](https://www.hanlp.com/) - 中文分词库

---

<div align="center">

**如果这个项目对你有帮助，欢迎 Star ⭐**

</div>
