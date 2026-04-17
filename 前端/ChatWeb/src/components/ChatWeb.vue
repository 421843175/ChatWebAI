<template>
  <div class="chat-shell" :class="{ 'has-model': currentTitle }">
    <aside class="chat-sidebar">
      <div class="sidebar-top">
        <div>
          <div class="sidebar-kicker">CONVERSATIONS</div>
          <h2>消息中心</h2>
        </div>
        <div class="sidebar-actions">
          <button class="side-icon" @click="toHome">首页</button>
          <button class="side-icon" v-show="$route.query.id == 0" @click="toChat(1)">商家</button>
          <button class="side-icon" v-show="$route.query.id == 1" @click="toChat(0)">客服</button>
        </div>
      </div>

      <Search ref="searchComponent" class="sidebar-search" @friendselected="friendselected"></Search>

      <div class="conversation-list">
        <Friends
          v-for="(item, index) in filteredContant"
          :key="index"
          :contant="item"
          class="friend"
          :class="{ active: currentTitle === item.username }"
          @click="clickFriends(item)"
          @delete="handleDelete">
        </Friends>
      </div>
    </aside>

    <section class="chat-main">
      <header class="chat-header">
        <div>
          <div class="chat-title">{{ currentNick || '请选择会话' }}</div>
          <div class="chat-subtitle">
            {{ currentTitle ? '实时对话已连接，可继续咨询商品、服务或售后问题。' : '从左侧选择联系人开始聊天。' }}
          </div>
        </div>
        <div class="chat-mode-badge">
          {{ $route.query.id == 1 ? '商家咨询' : '平台客服' }}
        </div>
      </header>

      <div class="chat-stage">
        <Chat
          ref="Message"
          @sendchat="sendchat"
          :isHide="currentTitle == '' ? 1 : 0"
          :contant="contant"
          :currentTitle="currentTitle">
        </Chat>
      </div>
    </section>

    <aside class="model-panel" v-if="currentTitle">
      <div class="model-panel-head">
        <span>AI 形象</span>
        <small>当前会话角色展示</small>
      </div>
      <div class="model-stage">
        <ViewModel
          :type="emotion"
          :currentTitle="currentTitle"
          ref="model"
          class="model-preview">
        </ViewModel>
      </div>
    </aside>
  </div>
</template>

<script>
import Search from './Chat/Search.vue'
import Friends from './Chat/Friends.vue'
import Chat from './Chat/Chat.vue'
import ViewModel from './ViewModel.vue'
import { mapGetters } from 'vuex'

export default {
  name: 'ChatWeb',
  components: {
    Search,
    Friends,
    Chat,
    ViewModel
  },
  data () {
    return {
      contant: [],
      currentTitle: '',
      currentNick: '',
      myusername: '',
      receiver: null,
      dataEmo: ['默认', '愤怒', '难过', '生气', '思考', '笑1', '笑2', '笑3', '震惊', '自信'],
      emotion: 0
    }
  },
  computed: {
    ...mapGetters('websocket', ['connectionStatus']),
    socket () {
      return this.$store.state.websocket.socket
    },
    filteredContant () {
      const searchComponent = this.$refs.searchComponent
      const searchKey = (searchComponent && searchComponent.searchinput && searchComponent.searchinput.toLowerCase()) || ''
      return this.contant.filter(item => item.username.toLowerCase().includes(searchKey))
    },
    // 监听被删除的会话
    deletedSession () {
      return this.$store.state.websocket.deletedSession
    },
    // 监听会话模式变更
    sessionModeChanged () {
      return this.$store.state.websocket.sessionModeChanged
    }
  },
  watch: {
    // 监听对方删除会话的通知
    deletedSession: function(newUsername) {
      console.log('【ChatWeb】watch deletedSession 触发:', newUsername)
      if (newUsername) {
        this.handleRemoteSessionDeleted(newUsername)
        // 清除状态，以便下次通知
        this.$store.commit('websocket/CLEAR_DELETED_SESSION')
      }
    },
    // 监听对方转人工的通知
    sessionModeChanged: function(newValue) {
      console.log('【ChatWeb】watch sessionModeChanged 触发:', newValue)
      if (newValue) {
        this.handleSessionModeChanged(newValue)
        // 清除状态
        this.$store.commit('websocket/CLEAR_SESSION_MODE_CHANGED')
      }
    }
  },
  methods: {
    toHome () {
      this.$router.push('/')
    },
    toChat (num) {
      this.$router.push({ name: 'ChatWeb', query: { id: num } })
    },
    // 处理对方删除会话的通知
    handleRemoteSessionDeleted(deletedUsername) {
      const index = this.contant.findIndex(item => item.username === deletedUsername)
      if (index !== -1) {
        this.contant.splice(index, 1)
      }

      // 如果被删除的是当前聊天对象，需要踢出并刷新页面
      if (this.currentTitle === deletedUsername) {
        this.currentTitle = ''
        this.currentNick = ''
        if (this.$refs.Message) {
          this.$refs.Message.messages = []
          this.$refs.Message.currentGood = null
          this.$refs.Message.suggestions = []
        }
        // 延迟跳转，让用户看到提示
        setTimeout(() => {
          this.$alert('对方已删除与你的会话。', '提示', {
            confirmButtonText: '确定',
            callback: () => {
              this.$router.go(0) // 刷新当前页面回到会话列表
            }
          })
        }, 100)
      }
    },
    // 处理对方转人工的通知
    handleSessionModeChanged(payload) {
      const { username, isRobot } = payload
      const index = this.contant.findIndex(item => item.username === username)
      if (index !== -1) {
        this.$set(this.contant, index, {
          ...this.contant[index],
          isRobot: isRobot
        })
      }
      console.log('【ChatWeb】已更新会话模式:', username, 'isRobot:', isRobot)
    },
    friendselected (item) {
      this.clickFriends(item)
    },
    initWebSocket () {
      // 监听 socket 状态
      this.$nextTick(() => {
        const socket = this.$store.state.websocket.socket
        if (socket && socket.readyState === WebSocket.OPEN) {
          console.log('【ChatWeb】Socket 已连接')
          this.sendAuth()
        } else {
          console.log('【ChatWeb】Socket 未连接或已断开，等待重连...')
        }
      })

      // 监听连接状态变化
      this.$watch(() => this.$store.state.websocket.isConnected, (connected) => {
        console.log('【ChatWeb】连接状态变化:', connected)
        if (connected) {
          this.sendAuth()
        }
      })
    },
    async handleDelete (item) {
      const isPlatformService = this.$route.query.id == 0

      if (isPlatformService) {
        // 平台客服：清空历史记录
        try {
          await this.$confirm(`确认清空与 ${item.nickname || item.username} 的聊天记录吗？`, '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          })

          const usertoken = localStorage.getItem('usertoken')
          const res = await this.$http.post(this.$constant.baseURL + '/chat/clearHistory', {
            usertoken,
            friendUsername: item.username
          })

          if (res.data.code === 200) {
            if (this.currentTitle === item.username) {
              if (this.$refs.Message) {
                this.$refs.Message.messages = []
                this.$refs.Message.currentGood = null
                this.$refs.Message.suggestions = []
              }
            }
            const index = this.contant.findIndex(c => c.username === item.username)
            if (index !== -1) {
              this.$set(this.contant[index], 'messageEnd', '')
              this.$set(this.contant[index], 'timestamp', '')
            }
            this.$message.success('历史记录已清空')
          }
        } catch (error) {
          if (error !== 'cancel') {
            this.$message.error(error.message || '清空历史记录失败')
          }
        }
      } else {
        // 商家/买家：删除会话
        try {
          await this.$confirm(`确认删除与 ${item.nickname || item.username} 的会话吗？`, '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          })

          const usertoken = localStorage.getItem('usertoken')
          const res = await this.$http.post(this.$constant.baseURL + '/chat/deleteSession', {
            usertoken,
            friendUsername: item.username
          })

          if (res.data.code === 200) {
            // 删除方直接删除，不弹任何提示
            // 对方会收到 WebSocket 通知
            this.contant = this.contant.filter(contant => contant.username !== item.username)

            // 如果是当前聊天对象，清空聊天区域
            if (this.currentTitle === item.username) {
              this.currentTitle = ''
              this.currentNick = ''
              if (this.$refs.Message) {
                this.$refs.Message.messages = []
                this.$refs.Message.currentGood = null
                this.$refs.Message.suggestions = []
              }
            }
          }
        } catch (error) {
          if (error !== 'cancel') {
            this.$message.error(error.message || '删除会话失败')
          }
        }
      }
    },
    clickFriends (item) {
      this.currentTitle = item.username
      this.currentNick = item.nickname
      this.$refs.Message.getHistory(this.currentTitle)
      this.clearUnRead(this.currentTitle)
      this.$refs.Message.loadCurrentGood(this.currentTitle)
      this.$refs.model.getModel(this.currentTitle)
    },
    clearUnRead (receiver) {
      const usertoken = localStorage.getItem('usertoken')
      this.$http.get(this.$constant.baseURL + '/chat/clearUnRead', { usertoken, receiver }).then((res) => {
        if (res.data.code === 200) {
          const index = this.contant.findIndex(item => item.username === receiver)
          if (index !== -1) {
            this.$set(this.contant[index], 'unreadnum', 0)
          }
          // 检查是否还有其他未读
          const hasAnyUnread = this.contant.some(item => item.unreadnum > 0)
          this.$store.commit('websocket/SET_UNREAD', hasAnyUnread)
        }
      })
    },
    sendAuth () {
      const token = localStorage.getItem('usertoken')
      if (this.socket) {
        this.socket.send(JSON.stringify({ type: 'AUTH', token: token }))
      }
    },
    handleWebSocketMessage (data) {
      console.log('【ChatWeb】收到 WebSocket 消息:', data.type)
      if (data.type == 'message') {
        this.$refs.Message.toMessage(data, this.currentTitle)
        const targetUsername = data.sender
        const index = this.contant.findIndex(item => item.username === targetUsername)
        const d = new Date()
        if (index !== -1) {
          const updatedContact = {
            ...this.contant[index],
            messageEnd: data.content,
            timestamp: d.getHours() + ':' + d.getMinutes()
          }
          const isCurrentChat = data.sender === this.currentTitle
          if (!isCurrentChat) {
            updatedContact.unreadnum = (updatedContact.unreadnum || 0) + 1
            this.updateRemoteUnread()
            // 更新全局未读状态
            this.$store.commit('websocket/SET_UNREAD', true)
          }
          this.$set(this.contant, index, updatedContact)
        }
        this.autoDi()
      }
    },
    async updateRemoteUnread () {
      const usertoken = localStorage.getItem('usertoken')
      this.$http.post(this.$constant.baseURL + '/chat/updateUnread', {
        usertoken,
        receiver: this.myusername
      }).then(() => {}).catch(() => {})
    },
    userFriendInfo (usertoken, roleid) {
      return this.$http.get(this.$constant.baseURL + '/chat/getFriend', { usertoken: usertoken, roleid: roleid }).then(res => {
        if (res.data.code == 200) {
          this.contant = res.data.data
          // 检查是否有未读消息，设置全局状态
          const hasAnyUnread = res.data.data.some(item => item.unreadnum > 0)
          this.$store.commit('websocket/SET_UNREAD', hasAnyUnread)
        }
      })
    },
    async sendchat (msg) {
      const usertoken = localStorage.getItem('usertoken')
      if (msg === '转人工') {
        this.artificial(usertoken, msg)
        return
      }

      // 先检查最新的会话状态（因为对方可能已经转人工）
      const currentContact = this.contant.find(item => item.username === this.currentTitle)
      const isRobot = currentContact ? currentContact.isRobot == 1 : true

      if (isRobot) {
        this.chatRobot(usertoken, msg)
      } else {
        this.chatPeople(usertoken, msg)
      }
    },
    artificial (usertoken, msg) {
      const userMsg = {
        sender: this.myusername,
        content: msg,
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false }),
        isSelf: true
      }
      this.$refs.Message.toMessage(userMsg, this.currentTitle)
      const merchant = this.currentTitle
      this.$http.get(this.$constant.baseURL + '/chat/toArtificial', { usertoken, merchant }).then((res) => {
        if (res.data.code == 200) {
          this.show(res.data.data)
          const index = this.contant.findIndex(item => item.username === this.currentTitle)
          if (index !== -1) {
            const updatedContact = {
              ...this.contant[index],
              isRobot: 0
            }
            this.$set(this.contant, index, updatedContact)
          }
        }
      }).catch(() => {})
    },
    show (message) {
      const botMsg = {
        sender: this.currentTitle,
        content: message,
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false }),
        isSelf: false
      }
      this.$refs.Message.toMessage(botMsg, this.currentTitle)
      const index = this.contant.findIndex(item => item.username === this.currentTitle)
      if (index !== -1) {
        const d = new Date()
        this.$set(this.contant, index, {
          ...this.contant[index],
          messageEnd: message,
          timestamp: d.getHours() + ':' + d.getMinutes().toString().padStart(2, '0')
        })
      }
    },
    autoDi () {
      this.$nextTick(() => {
        const container = document.querySelector('.messager-container')
        if (container) {
          container.scrollTop = container.scrollHeight
        }
      })
    },
    chatPeople (usertoken, msg) {
      const sendMessage = {
        type: 'MSG',
        token: usertoken,
        body: msg,
        to: this.currentTitle
      }
      this.socket.send(JSON.stringify(sendMessage))
      const index = this.contant.findIndex(item => item.username === this.currentTitle)
      if (index !== -1) {
        const d = new Date()
        this.$set(this.contant, index, {
          ...this.contant[index],
          messageEnd: msg,
          timestamp: d.getHours() + ':' + d.getMinutes()
        })
      }
    },
    chatRobot (usertoken, msg) {
      const userMsg = {
        sender: this.myusername,
        content: msg,
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false }),
        isSelf: true
      }
      this.$refs.Message.toMessage(userMsg, this.currentTitle)
      const receiver = this.currentTitle
      const content = msg
      const robot = { usertoken, receiver, content }
      this.$http.post(this.$constant.baseURL + '/chat/robot', robot).then(response => {
        const botMsg = {
          sender: this.currentTitle,
          content: response.data.data[1].content,
          time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false }),
          isSelf: false
        }
        this.$refs.Message.toMessage(botMsg, this.currentTitle)
        const index = this.contant.findIndex(item => item.username === this.currentTitle)
        if (index !== -1) {
          const d = new Date()
          this.$set(this.contant, index, {
            ...this.contant[index],
            messageEnd: response.data.data[1].content,
            timestamp: d.getHours() + ':' + d.getMinutes().toString().padStart(2, '0')
          })
        }
        this.autoDi()
      })
    },
    initPageData () {
      const usertoken = localStorage.getItem('usertoken')
      this.$http.get(this.$constant.baseURL + '/chat/getMy', { usertoken }).then((res) => {
        if (res.data.code === 200) {
          this.myusername = res.data.data.username
          const roleid = this.$route.query.id
          this.userFriendInfo(usertoken, roleid).then(() => {
            if (this.$route.query.user) {
              const target = this.contant.find(item => item.username === this.$route.query.user)
              if (target) {
                this.clickFriends(target)
              }
            }
          })
        }
      })
    }
  },
  created () {
    this.initWebSocket()
    this.initPageData()
    // 监听 WebSocket 消息事件
    this.$root.$on('websocket:message', this.handleWebSocketMessage)
  },
  beforeDestroy () {
    // 移除事件监听
    this.$root.$off('websocket:message', this.handleWebSocketMessage)
  }
}
</script>

<style scoped>
.chat-shell {
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr);
  gap: 18px;
  min-height: 100vh;
  padding: 18px;
}

.chat-shell.has-model {
  grid-template-columns: 300px minmax(0, 1fr) 260px;
}

.chat-sidebar,
.chat-main,
.model-panel {
  min-height: calc(100vh - 36px);
  border-radius: 28px;
  border: 1px solid rgba(115,140,189,0.14);
  background: rgba(255, 255, 255, 0.78);
  box-shadow: var(--shadow);
  backdrop-filter: blur(18px);
}

.chat-sidebar {
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.sidebar-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 18px;
}

.sidebar-kicker {
  color: var(--muted);
  font-size: 12px;
  letter-spacing: 0.2em;
  margin-bottom: 6px;
}

.sidebar-top h2 {
  margin: 0;
  font-size: 28px;
  color: #223454;
}

.sidebar-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.side-icon {
  padding: 10px 14px;
  border-radius: 14px;
  border: 1px solid rgba(115,140,189,0.14);
  background: rgba(245,248,255,0.9);
  color: var(--text);
  cursor: pointer;
}

.sidebar-search {
  margin-bottom: 18px;
}

.conversation-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  overflow-y: auto;
  padding-right: 4px;
}

.chat-main {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 22px 24px 18px;
  border-bottom: 1px solid rgba(115,140,189,0.12);
}

.chat-title {
  font-size: 28px;
  font-weight: 800;
  color: #203453;
}

.chat-subtitle {
  margin-top: 8px;
  color: var(--muted);
}

.chat-mode-badge {
  padding: 10px 16px;
  border-radius: 999px;
  color: var(--brand);
  background: rgba(62,207,142,0.1);
  border: 1px solid rgba(62,207,142,0.18);
}

.chat-stage {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.model-panel {
  padding: 18px 16px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-width: 0;
}

.model-stage {
  flex: 1;
  min-height: 0;
  margin-top: 14px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(247,250,255,0.95), rgba(239,245,255,0.9));
  border: 1px solid rgba(115,140,189,0.1);
  overflow: hidden;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.model-panel-head span,
.model-panel-head small {
  display: block;
}

.model-panel-head span {
  font-size: 24px;
  font-weight: 800;
  color: #233555;
}

.model-panel-head small {
  color: var(--muted);
  margin-top: 8px;
}

.model-preview {
  width: 100%;
  height: 100%;
  align-self: stretch;
}

@media (max-width: 1380px) {
  .chat-shell.has-model {
    grid-template-columns: 280px minmax(0, 1fr) 220px;
  }
}

@media (max-width: 1280px) {
  .chat-shell,
  .chat-shell.has-model {
    grid-template-columns: 280px minmax(0, 1fr);
  }

  .model-panel {
    display: none;
  }
}

@media (max-width: 860px) {
  .chat-shell {
    grid-template-columns: 1fr;
  }

  .chat-sidebar,
  .chat-main {
    min-height: auto;
  }
}
</style>
