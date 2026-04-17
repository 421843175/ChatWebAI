<template>
  <div class="chat-panel">
    <div v-if="isHide == 1" class="chat-empty">
      <div class="empty-badge">NO ACTIVE SESSION</div>
      <h3>选择一个联系人开始会话</h3>
      <p>商品咨询、售后回复、转人工处理都会在这里展开。</p>
    </div>

    <div v-else class="chat-inner">
      <div class="messager-container">
        <div v-if="currentGood != null && currentGood.name != null" class="consultation-bar">
          <div class="goods-card">
            <img :src="currentGood.src" class="goods-image">
            <div class="goods-info">
              <span class="goods-label">当前咨询商品</span>
              <strong>{{ currentGood.name }}</strong>
              <em>￥{{ currentGood.price }}</em>
            </div>
          </div>
          <div class="suggestions-wrapper" v-if="suggestions.length > 0">
            <div class="suggestions-header">
              <span>猜你想问</span>
              <button class="suggest-refresh" @click="refreshSuggestions">换一批</button>
            </div>
            <div class="suggestions-list">
              <span v-for="(item, index) in suggestions" :key="index" @click="sendSuggestion(item.question)" class="suggestion-item">
                {{ item.question }}
              </span>
            </div>
          </div>
        </div>

        <div v-for="(msg, index) in messages" :key="index" class="message-wrapper" :class="{ 'self-message': msg.isSelf }">
          <div class="avatar">
            <img :src="msg.avatar" v-if="msg.avatar">
            <div v-else class="default-avatar">{{ msg.sender ? msg.sender.charAt(0) : '?' }}</div>
          </div>

          <div class="bubble">
            <div class="content">{{ msg.content }}</div>
            <span class="time">{{ msg.time }}</span>
          </div>
        </div>
      </div>

      <div class="composer">
        <div class="composer-topline">
          <div class="composer-title-group">
            <span>输入消息</span>
            <em>像企业级客服工作台一样自然沟通</em>
          </div>
          <small>{{ num }}/500</small>
        </div>

        <div class="composer-editor-shell">
          <el-input type="textarea" resize="none" class="inputStyle" v-model="chatTest"></el-input>
          <div class="composer-editor-actions">
            <button class="score-btn" @click="dialogVisible = true">服务评价</button>
            <el-button type="primary" round @click="send">发送</el-button>
          </div>
        </div>
      </div>
    </div>

    <el-dialog title="服务评价" :visible.sync="dialogVisible" width="30%" center append-to-body @closed="handleDialogClose">
      <div class="rating-dialog">
        <div class="rating-section">
          <span>评分：</span>
          <el-rate v-model="score.value" :colors="['#99A9BF', '#F7BA2A', '#FF9900']" allow-half show-text>
            <template #default="{ value }">
              <span class="rate-text">{{ value }} 星</span>
            </template>
          </el-rate>
        </div>

        <div class="comment-section">
          <el-input type="textarea" :rows="4" placeholder="请输入评价内容（可选）" v-model="score.comment" maxlength="200" show-word-limit></el-input>
        </div>

        <div class="dialog-footer" style="text-align: center;">
          <el-button type="primary" @click="submitScore" :disabled="this.score.value === 0">提交评价</el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'Chat',
  props: ['isHide', 'contant', 'currentTitle'],
  data () {
    return {
      chatTest: '',
      messages: [],
      suggestions: [],
      currentGood: null,
      dialogVisible: false,
      score: {
        value: 0,
        comment: ''
      }
    }
  },
  computed: {
    num () {
      return this.chatTest.length
    }
  },
  methods: {
    send () {
      if (!this.chatTest || !this.chatTest.trim()) {
        return
      }
      this.chatTest = this.chatTest.replace(/</g, '&lt;').replace(/>/g, '&gt;')
      this.$emit('sendchat', this.chatTest)
      const d = new Date()
      const newMsg = {
        sender: '我',
        content: this.chatTest,
        time: d.getHours() + ':' + d.getMinutes(),
        avatar: '',
        isSelf: true
      }
      this.messages.push(newMsg)
      this.chatTest = ''
      this.scrollToBottom()
    },
    toMessage (data, currentTitle) {
      // 正在加载历史消息时，忽略 WebSocket 推送的消息
      if (this._isLoadingHistory) {
        return
      }
      if (data.sender == currentTitle) {
        // 防止重复添加相同消息（通过 sender + content 判断，简化为只比较核心字段）
        const isDuplicate = this.messages.some(msg =>
          msg.sender === data.sender &&
          msg.content === data.content
        )
        if (!isDuplicate) {
          this.messages.push(data)
          this.scrollToBottom()
        }
      }
    },
    scrollToBottom () {
      this.$nextTick(() => {
        const container = document.querySelector('.messager-container')
        if (container) {
          container.scrollTop = container.scrollHeight
        }
      })
    },
    getHistory (receiver) {
      // 标记正在加载历史，避免 WebSocket 消息在加载期间被添加
      this._isLoadingHistory = true
      this.messages = [] // 先清空，防止闪烁
      const usertoken = localStorage.getItem('usertoken')
      this.$http.get(this.$constant.baseURL + '/chat/getHistory', { usertoken, receiver }).then((res) => {
        if (res.data.code === 200) {
          this.messages = []
          res.data.data.forEach(msg => {
            // 历史消息去重（同 sender + content）
            const isDuplicate = this.messages.some(m => m.sender === msg.sender && m.content === msg.content)
            if (!isDuplicate) {
              this.messages.push({
                sender: msg.sender,
                content: msg.content,
                time: msg.time,
                isSelf: msg.isSelf,
                avatar: ''
              })
            }
          })
          this.scrollToBottom()
        }
      }).finally(() => {
        // 延迟清除加载状态，确保 WebSocket 消息不会在最后一刻被添加
        setTimeout(() => {
          this._isLoadingHistory = false
        }, 100)
      })
    },
    async loadCurrentGood (currentTitle) {
      try {
        const usertoken = localStorage.getItem('usertoken')
        const username2 = currentTitle
        const res = await this.$http.get(this.$constant.baseURL + '/goods/consultant', {
          usertoken: usertoken,
          username2: username2
        })
        if (res.data.code === 200) {
          this.currentGood = res.data.data
          await this.loadSuggestions()
        }
      } catch (error) {
        console.error('获取商品失败:', error)
      }
    },
    async loadSuggestions () {
      try {
        if (this.currentGood && this.currentGood.merchant != null && this.currentGood.id != null) {
          const res = await this.$http.get(this.$constant.baseURL + '/reply/suggestions', {
            merchant: this.currentGood.merchant,
            goodsId: this.currentGood.id
          })
          if (res.data.code === 200) {
            this.suggestions = res.data.data.map(item => ({ question: item.question }))
          }
        }
      } catch (error) {
        console.error('获取推荐问题失败:', error)
      }
    },
    async refreshSuggestions () {
      await this.loadSuggestions()
    },
    async sendSuggestion (question) {
      this.chatTest = question
      this.send()
    },
    handleDialogClose () {
      this.score = { value: 0, comment: '' }
    },
    submitScore () {
      const usertoken = localStorage.getItem('usertoken')
      const data = {
        usertoken,
        merchant: this.currentTitle,
        score: this.score.value,
        content: this.score.comment
      }
      this.$http.post(this.$constant.baseURL + '/evaluate/add', data).then((res) => {
        if (res.data.code === 200) {
          this.$message.success('评价成功')
          this.dialogVisible = false
          this.handleDialogClose()
        }
      }).catch((err) => {
        this.$message.error(err.message)
      })
    }
  }
}
</script>

<style scoped>
.chat-panel {
  height: 100%;
}

.chat-empty {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: var(--muted);
}

.empty-badge {
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(111,140,255,0.08);
  border: 1px solid rgba(111,140,255,0.14);
  color: var(--brand-2);
  letter-spacing: 0.18em;
  font-size: 12px;
}

.chat-empty h3 {
  margin: 18px 0 12px;
  color: var(--text);
  font-size: 32px;
}

.chat-inner {
  display: flex;
  flex-direction: column;
  height: 100%;
  background:
    radial-gradient(circle at top, rgba(111,140,255,0.12), transparent 34%),
    linear-gradient(180deg, rgba(255,255,255,0.78), rgba(247,250,255,0.92));
}

.messager-container {
  flex: 1;
  overflow-y: auto;
  padding: 24px 28px 18px;
  max-height: calc(100vh - 320px);
}

.consultation-bar {
  display: grid;
  grid-template-columns: minmax(280px, 0.95fr) minmax(0, 1.25fr);
  gap: 16px;
  margin-bottom: 24px;
}

.goods-card,
.suggestions-wrapper,
.composer {
  border-radius: 24px;
  border: 1px solid rgba(125, 145, 194, 0.16);
  background: rgba(255,255,255,0.78);
  box-shadow: 0 18px 40px rgba(166, 180, 221, 0.12);
  backdrop-filter: blur(12px);
}

.goods-card {
  display: flex;
  gap: 16px;
  padding: 18px;
  position: relative;
  overflow: hidden;
}

.goods-card::after {
  content: '';
  position: absolute;
  inset: auto -20% -55% 35%;
  height: 120px;
  background: radial-gradient(circle, rgba(111,140,255,0.14), transparent 70%);
  pointer-events: none;
}

.goods-image {
  width: 96px;
  height: 96px;
  object-fit: cover;
  border-radius: 20px;
  box-shadow: 0 12px 26px rgba(80, 106, 176, 0.18);
}

.goods-info {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 8px;
  position: relative;
  z-index: 1;
}

.goods-label {
  color: var(--muted);
  font-size: 12px;
  letter-spacing: 0.08em;
}

.goods-info strong {
  font-size: 18px;
  line-height: 1.5;
  color: #223454;
}

.goods-info em {
  font-style: normal;
  color: #e29a20;
  font-weight: 800;
  font-size: 16px;
}

.suggestions-wrapper {
  padding: 18px;
}

.suggestions-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
  color: #223555;
  font-weight: 700;
}

.suggest-refresh {
  border: 0;
  border-radius: 999px;
  background: rgba(111,140,255,0.1);
  color: var(--brand-2);
  cursor: pointer;
  padding: 8px 12px;
  transition: all 0.2s ease;
}

.suggest-refresh:hover {
  background: rgba(111,140,255,0.18);
  transform: translateY(-1px);
}

.suggestions-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.suggestion-item {
  padding: 11px 15px;
  border-radius: 999px;
  color: #465d8a;
  background: linear-gradient(135deg, rgba(111,140,255,0.12), rgba(62,207,142,0.08));
  border: 1px solid rgba(111,140,255,0.14);
  cursor: pointer;
  transition: all 0.2s ease;
}

.suggestion-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 18px rgba(111,140,255,0.14);
}

.message-wrapper {
  display: flex;
  gap: 14px;
  margin-bottom: 18px;
  align-items: flex-end;
}

.self-message {
  justify-content: flex-end;
}

.self-message .avatar {
  order: 2;
}

.avatar {
  flex-shrink: 0;
}

.avatar img,
.default-avatar {
  width: 44px;
  height: 44px;
  border-radius: 16px;
  box-shadow: 0 10px 18px rgba(93, 119, 180, 0.12);
}

.default-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #6f8cff, #3ecf8e);
  color: white;
  font-weight: 800;
}

.bubble {
  max-width: min(74%, 720px);
  padding: 16px 18px 12px;
  border-radius: 22px 22px 22px 8px;
  background: rgba(255,255,255,0.9);
  border: 1px solid rgba(125,145,194,0.16);
  box-shadow: 0 14px 28px rgba(178, 188, 221, 0.14);
}

.self-message .bubble {
  border-radius: 22px 22px 8px 22px;
  background: linear-gradient(135deg, rgba(62,207,142,0.18), rgba(111,140,255,0.18));
  border-color: rgba(111,140,255,0.08);
}

.content {
  line-height: 1.85;
  word-break: break-word;
  color: #24324a;
  font-size: 15px;
}

.time {
  display: block;
  margin-top: 10px;
  text-align: right;
  font-size: 12px;
  color: rgba(86, 103, 140, 0.72);
}

.composer {
  margin: 0 24px 24px;
  padding: 16px;
  position: relative;
  border-radius: 28px;
  background:
    linear-gradient(180deg, rgba(255,255,255,0.92), rgba(245,249,255,0.96));
  border: 1px solid rgba(148, 166, 210, 0.18);
  box-shadow:
    0 24px 48px rgba(162, 177, 214, 0.18),
    inset 0 1px 0 rgba(255,255,255,0.86);
}

.composer::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background:
    radial-gradient(circle at top left, rgba(111,140,255,0.12), transparent 34%),
    radial-gradient(circle at right bottom, rgba(62,207,142,0.10), transparent 28%);
  pointer-events: none;
}

.composer-topline,
.composer-editor-shell {
  position: relative;
  z-index: 1;
}

.composer-topline {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 14px;
  color: var(--muted);
}

.composer-title-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.composer-title-group span {
  font-size: 18px;
  font-weight: 800;
  color: #23395d;
  letter-spacing: 0.01em;
}

.composer-title-group em {
  font-style: normal;
  font-size: 12px;
  color: rgba(88, 105, 142, 0.78);
  letter-spacing: 0.04em;
}

.composer-topline small {
  padding: 8px 12px;
  border-radius: 999px;
  background: rgba(111,140,255,0.08);
  color: #6a7ea7;
  font-weight: 700;
}

.composer-editor-shell {
  padding: 14px;
  border-radius: 22px;
  background: rgba(255,255,255,0.88);
  border: 1px solid rgba(135, 156, 204, 0.16);
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.92),
    0 12px 24px rgba(178, 190, 223, 0.12);
}

.composer-editor-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
  margin-top: 14px;
}

.score-btn {
  padding: 11px 18px;
  border-radius: 14px;
  border: 1px solid rgba(115,140,189,0.14);
  background: linear-gradient(180deg, rgba(255,255,255,0.96), rgba(243,247,255,0.96));
  color: #314460;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 700;
}

.score-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 18px rgba(111,140,255,0.12);
}

::v-deep .el-textarea__inner {
  min-height: 132px !important;
  border-radius: 18px;
  border: 1px solid rgba(115,140,189,0.12);
  background:
    linear-gradient(180deg, rgba(255,255,255,0.98), rgba(250,252,255,0.98));
  color: #21324d;
  padding: 18px 18px;
  line-height: 1.85;
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.95),
    inset 0 -1px 0 rgba(235, 241, 252, 0.88);
  font-size: 15px;
}

::v-deep .el-textarea__inner::placeholder {
  color: rgba(123, 137, 167, 0.7);
}

::v-deep .el-textarea__inner:focus {
  border-color: rgba(111,140,255,0.42);
  box-shadow:
    0 0 0 4px rgba(111,140,255,0.08),
    0 12px 24px rgba(111,140,255,0.10);
}

::v-deep .composer-editor-actions .el-button--primary {
  border: none;
  min-width: 112px;
  padding: 12px 28px;
  border-radius: 16px;
  background: linear-gradient(135deg, #3a7bff, #45b8ff 58%, #6ce0d6);
  box-shadow:
    0 16px 28px rgba(63, 131, 255, 0.24),
    inset 0 1px 0 rgba(255,255,255,0.35);
  font-weight: 700;
  letter-spacing: 0.08em;
}

::v-deep .composer-editor-actions .el-button--primary:hover,
::v-deep .composer-editor-actions .el-button--primary:focus {
  background: linear-gradient(135deg, #2f6ef4, #34a9ff 58%, #56d7c9);
  transform: translateY(-1px);
}

@media (max-width: 960px) {
  .consultation-bar {
    grid-template-columns: 1fr;
  }

  .messager-container {
    padding: 18px;
  }

  .composer {
    margin: 0 18px 18px;
  }

  .composer-editor-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .score-btn {
    width: 100%;
  }

  .bubble {
    max-width: 88%;
  }
}
</style>

