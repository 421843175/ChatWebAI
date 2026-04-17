import Vue from 'vue'
import VueRouter from 'vue-router'
import ChatWeb from '@/components/ChatWeb'
import Login from '@/components/Login'
import shops from '../components/shops.vue'
import Setting from '../components/Setting.vue'
import GoodsDetail from '../components/GoodsDetail.vue'

const originalPush = VueRouter.prototype.push;
VueRouter.prototype.push = function push(location) {
  return originalPush.call(this, location).catch(err => err);
}

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Shops',
    component: shops,
    meta: { isAuth: true }
  },
  {
    path: '/goods/detail',
    name: 'GoodsDetail',
    component: GoodsDetail,
    meta: { isAuth: true }
  },
  {
    path: '/login',
    component: Login
  },
  {
    path: '/chat/:id?:user?',
    name: 'ChatWeb',
    component: ChatWeb,
    meta: { isAuth: true },
    props: route => ({ key: route.fullPath })
  },
  {
    path: '/setting',
    name: 'Setting',
    component: Setting,
    meta: { isAuth: true }
  },
]

const router = new VueRouter({
  mode: 'history',
  routes: routes,
  scrollBehavior() {
    return { x: 0, y: 0 }
  }
})

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.isAuth)) {
    const hasToken = localStorage.getItem('usertoken')

    if (!hasToken) {
      console.log('需要登录认证')
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
      return
    }
  }

  next()
})

export default router
