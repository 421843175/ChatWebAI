# ChatWeb - 智能客服聊天系统

基于 Spring Boot + Vue.js + Flutter 的智能客服聊天系统，支持 AI 自动回复、WebSocket 实时通信。

## 项目架构

```
┌─────────────────────────────────────────────────────────────┐
│                        用户层                                │
├─────────────────────┬─────────────────────┬─────────────────┤
│   Web 前端 (Vue.js)  │  移动端 (Flutter)    │   后端 API      │
│   http://localhost:8081│   Android/iOS      │   Port: 8090    │
└─────────────────────┴─────────────────────┴─────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Spring Boot 后端服务                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  HTTP API    │  │  WebSocket   │  │   AI 客服    │      │
│  │  Port: 8090  │  │  Port: 8091  │  │  DeepSeek   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                │                  │               │
│         └────────────────┼──────────────────┘               │
│                          ▼                                  │
│              ┌──────────────────────┐                       │
│              │  MySQL  │  Redis      │                       │
│              │  数据存储 │  缓存/会话记忆 │                       │
│              └──────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端 | Vue.js 2 + Vuex | 实时聊天界面 |
| 移动端 | Flutter | Android/iOS 双平台 |
| 后端 | Spring Boot 2.7 | RESTful API |
| WebSocket | Netty | 实时消息推送 |
| AI 客服 | DeepSeek API | 智能对话 |
| 数据库 | MySQL 8 | 持久化存储 |
| 缓存 | Redis | 会话记忆、通道管理 |
| 部署 | Docker Compose | 容器化部署 |

## 项目结构

```
├── 前端/                      # Vue.js Web 前端
│   ├── ChatWeb/              # 前端源码
│   ├── Dockerfile            # 前端 Nginx 镜像构建
│   └── NOTICE.md             # 前端技术文档
│
├── backend/                   # Spring Boot 后端
│   ├── ChatWEBAI/            # 后端源码
│   └── Dockerfile            # 后端 Java 镜像构建
│
├── mobile_client/            # Flutter 移动端
│   └── lib/                  # Flutter 源码
│
├── myjavadockertest/        # Docker 部署配置
│   ├── docker-compose.yml    # 容器编排配置
│   ├── backend/              # 后端 Dockerfile
│   └── frontend/             # 前端 Dockerfile
│
└── 数据库/                    # 数据库初始化脚本
```

---

## 快速开始

### 1. 后端运行

```bash
cd backend/ChatWEBAI

# 导入数据库
mysql -u root -p < ../../数据库/init.sql

# 启动后端（开发环境）
mvn spring-boot:run

# 或打包运行
mvn clean package -DskipTests
java -jar target/CHATWEB-0.0.1-SNAPSHOT.jar
```

后端端口：`8090` (HTTP API) | `8091` (WebSocket)

### 2. 前端运行

```bash
cd 前端/ChatWeb

# 安装依赖
npm install

# 开发环境启动
npm run serve

# 访问 http://localhost:8081
```

### 3. Flutter 移动端

```bash
cd mobile_client

# 获取依赖
flutter pub get

# 运行（debug）
flutter run

# 构建 APK
flutter build apk --release
```

---

## Docker Compose 部署

### 部署架构

```
┌─────────────────────────────────────────────────────────────┐
│                      单机多容器部署                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│   │  MySQL   │  │  Redis   │  │ Backend-1│  │ Backend-2│     │
│   │ (容器1)  │  │ (容器2)  │  │ (容器3)  │  │ (容器4)  │     │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘     │
│                                           │                │
│                                           ▼                │
│                                    ┌─────────┐           │
│                                    │ Backend-3│           │
│                                    │ (容器5)  │           │
│                                           │                │
│                                           ▼                │
│                                    ┌─────────┐           │
│                                    │  Nginx   │           │
│                                    │ (容器6)  │           │
│                                    │ 负载均衡  │           │
│                                    └────┬────┘           │
│                                         │                  │
│                                    用户访问入口              │
└─────────────────────────────────────────────────────────────┘
```

### Dockerfiile 后端

```docker
# backend/Dockerfile
FROM eclipse-temurin:17-jre-alpine

# 拷贝 JAR 包
COPY ChatWEBAI.jar /app.jar

# 暴露端口  这里有8091是因为我们现在服务是需要websocket 端口 8091
EXPOSE 8090 8091

# 启动命令
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Nginx 配置（负载均衡

```docker
# nginx.conf
events {
    worker_connections 1024;
}

http {
    # 后端 API 负载均衡
    upstream api_backend {
        least_conn;  # 最少连接优先
        server backend:8090;  # Docker 内部网络
    }

    # WebSocket 负载均衡（实际上只有1个实例）
    upstream ws_backend {
        server backend:8091;
    }

    server {
        listen 80;

        # 前端静态文件
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # API 请求代理
        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # WebSocket 升级
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

### **Dockerfile（前端 + Nginx）**

```docker
# 前端/Dockerfile
FROM nginx:alpine

# 删除默认配置
RUN rm /etc/nginx/nginx.conf

# 拷贝前端静态文件和 Nginx 配置 这里是从宿主机拷贝到容器
COPY dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose.yml（完整配置）**

```docker
# docker-compose.yml
version: '3.8'

services:
  # ==================== 数据库 ====================
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: 你的MySQL密码
      MYSQL_DATABASE: chatweb
    ports:
      - "3306:3306"           # 暴露给宿主机（方便本地调试）
    volumes:
      - mysql_data:/var/lib/mysql  # 数据持久化
      - ./mysql/init:/docker-entrypoint-initdb.d  # 自动执行这里面的.sql文件（用于创库创表）
    restart: unless-stopped
    networks:
      - chat-network

  # ==================== 缓存 ====================
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped 
    # 除非手动stop，否则一直重启
    networks:
      - chat-network

  # ==================== 后端服务（多实例） ====================
  backend:
    build: ./backend              # 使用 backend/Dockerfile 构建
    volumes:
      - ./ChatWEBAI.jar:/app.jar  # 挂载 JAR 包
    expose:
      - "8090"                    # 只给内部网络用，不暴露到宿主机
      - "8091"                    # WebSocket 端口
    depends_on:
      - mysql
      - redis
    deploy:
      replicas: 3                 # ← 启动 3 个实例！
    restart: unless-stopped
    networks:
      - chat-network

  # ==================== 前端服务（Nginx） ====================
  frontend:
    build: ./前端                  # 使用前端/Dockerfile 构建
    ports:
      - "8081:80"                # 用户访问入口
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - chat-network

networks:
  chat-network:
    driver: bridge

volumes:
  mysql_data:
  redis_data:
```

### 打包流程

#### 1. 打包后端

```bash
cd backend/ChatWEBAI

# Maven 打包
mvn clean package -DskipTests

# 产出文件
# backend/ChatWEBAI/target/CHATWEB-0.0.1-SNAPSHOT.jar
```

#### 2. 打包前端

```bash
cd 前端/ChatWeb

# 安装依赖
npm install

# 打包成静态文件
npm run build

# 产出目录
# 前端/ChatWeb/dist/
```

### 部署命令

```bash
cd myjavadockertest

# 首次启动
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f backend

# 停止服务
docker-compose down

# 重新构建并启动
docker-compose up -d --build

# 重启某个服务
docker-compose restart backend
```

### 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端 | http://服务器IP:8081 | 用户访问入口 |
| MySQL | localhost:3306 | 本地调试用 |
| Redis | localhost:6379 | 本地调试用 |

### 注意事项

**WebSocket 多实例限制：**
- 后端配置了 3 个实例（`replicas: 3`），但 WebSocket（端口 8091）实际只有 1 个实例在用
- 原因：ChannelMap 存在内存中，多实例之间不共享 后续版本解决
- 如果需要真正的 WebSocket 集群，需要用 Redis Pub/Sub 同步

**端口配置：**
- `expose` 仅暴露给内部网络，不映射到宿主机（避免多实例端口冲突）
- `ports` 映射用于本地调试

---

## 功能特性

### Web 前端
- 用户登录/注册
- 实时聊天（WebSocket）
- AI 客服自动回复
- 会话模式切换（AI / 人工）
- 未读消息小红点提醒

### Flutter 移动端
- 跨平台支持（Android/iOS）
- 实时消息推送
- 图片发送
- 历史消息查看

### 后端服务
- RESTful API
- WebSocket 实时通信
- DeepSeek AI 对话
- Redis 会话记忆
- JWT 用户认证

---

## 主要技术说明

### WebSocket 消息类型

**前端 → 后端：**

| type | 用途 |
|------|------|
| `AUTH` | 用户认证（连接建立后发送） |
| `MSG` | 发送聊天消息 |

**后端 → 前端：**

| type | 用途 |
|------|------|
| `message` | 普通聊天消息 |
| `session_deleted` | 会话删除通知 |
| `session_mode_changed` | 会话模式变更 |

### Redis 在项目中的作用

| 场景 | Redis 作用 |
|------|------------|
| AI 对话记忆 | 持久化聊天上下文，供 AI 回复时参考 |
| WebSocket 通道 | 跟踪用户在线状态，辅助消息路由 |

---

## 环境要求

| 组件 | 版本要求 |
|------|----------|
| JDK | 17+ |
| Node.js | 16+ |
| Flutter | 3.3.0+ |
| MySQL | 8.0+ |
| Redis | 6.0+ |
| Docker | 20.10+ |
| Docker Compose | 2.0+ |

---

## 许可证

MIT License
