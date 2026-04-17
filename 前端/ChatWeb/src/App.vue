<template>
  <div class="app-shell">
    <router-view :key="$route.fullPath"/>
  </div>
</template>

<script>
export default {
  name: 'App',
  created () {
    this.initWebSocket()
  },
  methods: {
    initWebSocket () {
      // 创建新的 socket
      const newSocket = new WebSocket('ws://localhost:8091/socket.io')
      this.$store.commit('websocket/SET_SOCKET', newSocket)
      this.$store.commit('websocket/SET_CONNECTED', false)

      newSocket.onopen = () => {
        this.$store.commit('websocket/SET_CONNECTED', true)
        console.log('【App.vue】WebSocket 连接成功')
        // WebSocket 连接成功后发送认证
        const token = localStorage.getItem('usertoken')
        if (token) {
          newSocket.send(JSON.stringify({ type: 'AUTH', token: token }))
        }
      }

      newSocket.onmessage = (event) => {
        this.handleGlobalMessage(event)
      }

      newSocket.onclose = () => {
        console.log('【App.vue】WebSocket 连接断开，尝试重连...')
        this.$store.commit('websocket/SET_CONNECTED', false)
        // 清除 socket 引用，以便重新创建
        this.$store.commit('websocket/SET_SOCKET', null)
        // 延迟重连
        setTimeout(() => {
          this.initWebSocket()
        }, 3000)
      }

      newSocket.onerror = (error) => {
        console.error('WebSocket 错误:', error)
      }
    },
    handleGlobalMessage (event) {
      try {
        const data = JSON.parse(event.data)
        console.log('【App.vue】收到 WebSocket 消息:', data.type, data)

        // 派发事件让子组件可以监听
        this.$root.$emit('websocket:message', data)

        if (data.type === 'message') {
          // 收到消息就设置未读状态
          this.$store.commit('websocket/SET_UNREAD', true)
        } else if (data.type === 'session_deleted') {
          // 对方删除了会话，通知前端处理
          console.log('【App.vue】收到会话删除通知:', data.username)
          this.$store.commit('websocket/SET_DELETED_SESSION', data.username)
          this.$message.warning(`对方已删除与你的会话`)
        } else if (data.type === 'session_mode_changed') {
          // 对方转人工了，更新会话模式
          console.log('【App.vue】收到会话模式变更通知:', data.username, 'isRobot:', data.isRobot)
          this.$store.commit('websocket/SET_SESSION_MODE_CHANGED', {
            username: data.username,
            isRobot: data.isRobot
          })
          this.$message.info(`对方已转人工服务`)
        }
      } catch (error) {
        console.error('处理 WebSocket 消息失败:', error)
      }
    }
  }
}
</script>

<style>
:root {
  --bg: #f6f9ff;
  --bg-soft: #eef4ff;
  --panel: rgba(255, 255, 255, 0.82);
  --panel-strong: #ffffff;
  --line: rgba(115, 140, 189, 0.18);
  --line-strong: rgba(115, 140, 189, 0.28);
  --text: #24324a;
  --muted: #6e7f9d;
  --brand: #3ecf8e;
  --brand-2: #6f8cff;
  --danger: #ff7d8f;
  --warning: #ffbe55;
  --shadow: 0 24px 70px rgba(84, 116, 168, 0.16);
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-md: 16px;
}

html,
body,
#app {
  width: 100%;
  min-height: 100%;
  margin: 0;
  padding: 0;
}

body {
  font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
  color: var(--text);
  background:
    radial-gradient(circle at top left, rgba(111, 140, 255, 0.2), transparent 30%),
    radial-gradient(circle at 85% 15%, rgba(62, 207, 142, 0.16), transparent 22%),
    radial-gradient(circle at bottom right, rgba(255, 125, 143, 0.14), transparent 24%),
    linear-gradient(180deg, #fbfdff 0%, #f5f9ff 48%, #eef4ff 100%);
  background-attachment: fixed;
}

body::before {
  content: "";
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: -1;
  background-image:
    linear-gradient(rgba(118, 142, 186, 0.08) 1px, transparent 1px),
    linear-gradient(90deg, rgba(118, 142, 186, 0.08) 1px, transparent 1px);
  background-size: 32px 32px;
  mask-image: radial-gradient(circle at center, black 35%, transparent 92%);
}

* {
  box-sizing: border-box;
}

.el-message,
.el-message-box {
  backdrop-filter: blur(18px);
}

.el-dialog {
  backdrop-filter: blur(18px);
  z-index: 3001 !important;
  margin-top: 15vh;
}

.el-dialog__wrapper {
  z-index: 3000 !important;
  background-color: rgba(0, 0, 0, 0.5) !important;
}

.el-dialog__wrapper > * {
  z-index: 3001;
}

.app-shell {
  min-height: 100vh;
}
</style>
