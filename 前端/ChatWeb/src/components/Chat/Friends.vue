<template>
  <div class="friend-item" :class="$attrs.class" @click="$emit('click')">
    <div class="friend-avatar-wrap" @click.stop>
      <el-avatar :size="52" :src="contant.head" class="friend-avatar-base"></el-avatar>
      <button class="avatar-delete-mask" title="删除会话" @click.stop="$emit('delete', contant)">
        <span class="delete-cross">×</span>
      </button>
      <span v-if="contant.unreadnum!=0" class="friend-unread">{{ contant.unreadnum > 99 ? '99+' : contant.unreadnum }}</span>
    </div>

    <div class="friend-main">
      <div class="friend-topline">
        <span class="username">{{ contant.nickname }}</span>
        <span class="timestamp">{{ contant.timestamp != null ? contant.timestamp : '' }}</span>
      </div>
      <div class="content-line">
        <span class="message-content">
          {{ contant.messageEnd != null ? (contant.messageEnd.length > 18 ? contant.messageEnd.slice(0, 18) + '...' : contant.messageEnd) : '开始新的会话吧' }}
        </span>
        <span class="friend-status">{{ contant.isRobot == 1 ? 'AI' : '人工' }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Friends',
  inheritAttrs: false,
  props: ['contant']
}
</script>

<style scoped>
.friend-item {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 14px;
  border-radius: 20px;
  border: 1px solid rgba(255,255,255,0.06);
  background: rgba(255,255,255,0.03);
  cursor: pointer;
  transition: transform 0.22s ease, border-color 0.22s ease, background 0.22s ease;
}

.friend-item:hover,
.friend-item.active {
  transform: translateY(-2px);
  border-color: rgba(116,242,206,0.18);
  background: linear-gradient(180deg, rgba(116,242,206,0.08), rgba(122,162,255,0.08));
}

.friend-avatar-wrap {
  position: relative;
  flex-shrink: 0;
  width: 52px;
  height: 52px;
}

.friend-avatar-base {
  width: 52px;
  height: 52px;
}

.avatar-delete-mask {
  position: absolute;
  inset: 0;
  width: 52px;
  height: 52px;
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(216, 90, 99, 0);
  color: transparent;
  cursor: pointer;
  transition: background 0.2s ease, color 0.2s ease;
}

.friend-avatar-wrap:hover .avatar-delete-mask {
  background: rgba(216, 90, 99, 0.88);
  color: #fff;
}

.delete-cross {
  font-size: 28px;
  line-height: 1;
  transform: translateY(-1px);
}

.friend-unread {
  position: absolute;
  top: -6px;
  right: -6px;
  min-width: 22px;
  height: 22px;
  border-radius: 999px;
  padding: 0 6px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #ff6f86;
  color: white;
  font-size: 12px;
  font-weight: 700;
  z-index: 2;
}

.friend-main {
  min-width: 0;
  flex: 1;
}

.friend-topline,
.content-line {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.friend-topline {
  margin-bottom: 8px;
}

.username {
  font-weight: 700;
  color: var(--text);
}

.timestamp,
.message-content {
  color: var(--muted);
}

.timestamp {
  font-size: 12px;
  flex-shrink: 0;
}

.message-content {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.friend-status {
  flex-shrink: 0;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 999px;
  background: rgba(255,255,255,0.08);
  color: #dbe7ff;
}
</style>
