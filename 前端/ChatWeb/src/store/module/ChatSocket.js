const state = {
    socket: null,
    isConnected: false,
    hasUnread: false,  // 全局未读消息状态
    deletedSession: null,  // 被删除的会话用户名
    sessionModeChanged: null  // 会话模式变更 {username, isRobot}
  }

  const mutations = {
    SET_SOCKET(state, socket) {
      state.socket = socket
    },
    SET_CONNECTED(state, status) {
      state.isConnected = status
    },
    SET_UNREAD(state, hasUnread) {
      state.hasUnread = hasUnread
    },
    SET_DELETED_SESSION(state, username) {
      state.deletedSession = username
    },
    CLEAR_DELETED_SESSION(state) {
      state.deletedSession = null
    },
    SET_SESSION_MODE_CHANGED(state, payload) {
      state.sessionModeChanged = payload
    },
    CLEAR_SESSION_MODE_CHANGED(state) {
      state.sessionModeChanged = null
    }
  }

  export default {
    namespaced: true,
    state,
    mutations
  }