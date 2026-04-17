import Vue from 'vue'
import App from './App'
import router from './router'

import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'


import Vuex from 'vuex'  // 修正导入名称

// 自定义模块
import http from './utils/request'
import common from './utils/common'
import constant from './utils/constant'

// Vuex Store 配置
import websocket from './store/module/ChatSocket'

Vue.config.productionTip = false

// 初始化插件
Vue.use(ElementUI)
Vue.use(Vuex)  // 必须先调用这个！

// 创建 Store 实例
const store = new Vuex.Store({
  modules: {
    websocket
  }
})

// 挂载全局属性
Vue.prototype.$http = http
Vue.prototype.$common = common
Vue.prototype.$constant = constant

// 创建 Vue 实例
new Vue({
  el: '#app',
  router,
  store,  // 注入 store
  components: { App },
  template: '<App/>'
})