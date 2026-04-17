<template>
  <div class="shop-page">
    <header class="top-nav fade-in-top">
      <div class="brand-block">
        <div class="brand-mark">CW</div>
        <div class="brand-copy">
          <strong>ChatWeb Select</strong>
          <span>高质感数字商品客服平台</span>
        </div>
      </div>

      <nav class="nav-links">
        <button class="nav-link active" @click="scrollToGoods">商品</button>
        <button class="nav-link" @click="toChat(0)">客服</button>
        <button v-if="role == 1" class="nav-link" @click="toSetting">卖家中心</button>
      </nav>

      <div class="nav-actions">
        <button class="icon-entry" @click="account" title="账号管理">
          <span class="icon-badge">◌</span>
          <span>账号</span>
        </button>
        <button class="icon-entry" @click="toChat(1)" title="商家会话">
          <span class="icon-badge">✦</span>
          <span class="unread-dot" v-if="hasUnread"></span>
          <span>会话</span>
        </button>
        <button class="icon-entry" @click="toChat(0)" title="平台客服">
          <span class="icon-badge">◎</span>
          <span>客服</span>
        </button>
        <button v-if="role == 1" class="icon-entry" @click="toSetting" title="卖家中心">
          <span class="icon-badge">▣</span>
          <span>工作台</span>
        </button>
        <button class="icon-entry danger" @click="back" title="退出登录">
          <span class="icon-badge">↗</span>
          <span>退出</span>
        </button>
      </div>
    </header>

    <section class="collection-banner tilt-in-fwd-tr">
      <div>
        <div class="collection-kicker">EDITOR'S SELECTION</div>
        <div class="collection-title">精选电商数字时代商品陈列馆</div>
        <div class="collection-desc">用更高端的展陈方式，让用户一眼感受到商品价值。</div>
      </div>
      <div class="collection-side">
        <div class="profile-chip">
          <el-avatar :size="42" :src="head"></el-avatar>
          <div>
            <strong>{{ nick || '未命名用户' }}</strong>
            <span>{{ role == 1 ? '卖家工作台' : '买家尊享模式' }}</span>
          </div>
        </div>
        <div class="collection-badge">Premium Selection</div>
      </div>
    </section>

    <section class="market-toolbar fade-in-up delay-1" ref="goodsSection">
      <div>
        <div class="toolbar-title">热卖商品</div>
        <div class="toolbar-desc">数字化电商 / 可视化风评 / AI 咨询商品一站式精选呈现</div>
      </div>
      <!-- <div v-if="debugInfo" style="background:#ffeb3b;color:#000;padding:10px;border-radius:8px;margin-top:10px;">
        <strong>调试信息:</strong> {{ debugInfo }}
      </div> -->
      <div class="toolbar-tools">
        <div class="search-box">
          <input
            v-model.trim="searchKeyword"
            class="search-input"
            type="text"
            placeholder="搜索商品名 / 商家 / 关键词"
            @keyup.enter="handleSearch">
          <button class="search-btn" @click="handleSearch">搜索</button>
          <button v-if="searchKeyword || isSearching" class="search-reset-btn" @click="resetSearch">清空</button>
        </div>
        <div class="toolbar-stats">
          <span>{{ goods.length }}</span>
          <em>{{ isSearching ? '条搜索结果' : '件在售商品' }}</em>
        </div>
      </div>
    </section>

    <div class="goods-grid" :class="{ 'single-result-grid': goods.length === 1 }">
      <article class="product-card fade-in-up" v-for="(item, index) in goods" :key="index" @click="goDetail(item)" :style="{ animationDelay: `${Math.min(index, 7) * 80}ms` }">
        <div class="product-cover-wrap">
          <img :src="item.src" class="product-cover">
          <div class="product-overlay">
            <span>Premium Preview</span>
            <strong>进入详情</strong>
          </div>
          <div v-if="isPremium(item.star)" class="premium-badge">精品臻选</div>
        </div>
        <div class="product-body">
          <div class="product-topline">
            <div class="product-tag" :class="{ muted: !isPremium(item.star) }">{{ isPremium(item.star) ? '精品臻选' : '优选商品' }}</div>
            <div class="product-serial">NO.{{ String(index + 1).padStart(2, '0') }}</div>
          </div>
          <h3>{{ item.name }}</h3>
          <p class="product-summary">{{ getSummary(item.description) }}</p>
          <div class="product-bottom">
            <div class="product-price">
              <small>专属咨询价</small>
              <strong>￥{{ item.price }}</strong>
            </div>
            <button class="buy-btn" @click.stop="goDetail(item)">
              <span class="buy-btn-text">查看详情</span>
              <span class="buy-btn-arrow">→</span>
            </button>
          </div>
        </div>
      </article>
    </div>

    <Account :visible="accountDialogVisible" @close="cancelAccount"></Account>
  </div>
</template>

<script>
import Account from './Chat/Account.vue'

export default {
  name: 'Shops',
  components: {
    Account
  },
  data () {
    return {
      nick: '',
      head: '',
      role: 2,
      goods: [],
      searchKeyword: '',
      isSearching: false,
      accountDialogVisible: false,
      debugInfo: '',
      // 分页相关
      currentPage: 1,
      pageSize: 10,
      totalPages: 1,
      isLoadingMore: false,
      hasMoreData: true
    }
  },
  computed: {
    hasUnread () {
      return this.$store.state.websocket.hasUnread
    }
  },
  methods: {
    async loadGoodsList () {
      // 搜索模式下不走分页
      if (this.isSearching) return

      this.debugInfo = '正在请求商品列表...'
      try {
        const url = this.$constant.baseURL + '/goods/list'
        const res = await this.$http.get(url, {
          page: this.currentPage,
          size: this.pageSize
        })
        if (res.data.code == 200) {
          const pageData = res.data.data
          const records = pageData.records || pageData

          if (this.currentPage === 1) {
            // 第一页：替换数据
            this.goods = records
          } else {
            // 后续页：追加数据
            this.goods = [...this.goods, ...records]
          }

          // 更新分页信息
          this.totalPages = pageData.pages || 1
          this.hasMoreData = this.currentPage < this.totalPages

          this.debugInfo = `加载成功，第${this.currentPage}页，商品数量: ${this.goods.length}`
        } else {
          this.debugInfo = `接口错误: code=${res.data.code}, message=${res.data.message}`
        }
      } catch (error) {
        this.debugInfo = `请求失败: ${error.message || error}`
      }
    },

    // 下拉刷新：重置到第一页
    async handleRefresh () {
      this.currentPage = 1
      this.hasMoreData = true
      await this.loadGoodsList()
    },

    // 加载更多：页码+1
    async loadMoreGoods () {
      if (this.isLoadingMore || !this.hasMoreData || this.isSearching) return

      this.isLoadingMore = true
      this.currentPage++
      await this.loadGoodsList()
      this.isLoadingMore = false
    },
    async handleSearch () {
      if (!this.searchKeyword) {
        this.isSearching = false
        this.currentPage = 1
        this.hasMoreData = true
        this.loadGoodsList()
        return
      }
      this.currentPage = 1
      this.hasMoreData = false // 搜索模式不分页
      const res = await this.$http.get(this.$constant.baseURL + '/goods/search', { keyword: this.searchKeyword })
      if (res.data.code == 200) {
        this.goods = res.data.data
        this.isSearching = true
      }
    },
    async resetSearch () {
      this.searchKeyword = ''
      this.isSearching = false
      this.currentPage = 1
      this.hasMoreData = true
      await this.loadGoodsList()
    },
    getSummary (description) {
      if (!description) {
        return '点击进入详情页查看完整商品描述与咨询信息。'
      }

      try {
        const parsed = JSON.parse(description)
        const parts = []

        if (parsed.brand) {
          parts.push(`品牌：${parsed.brand}`)
        }
        if (parsed.productName) {
          parts.push(`品名：${parsed.productName}`)
        }
        if (Array.isArray(parsed.features) && parsed.features.length) {
          parts.push(`特点：${parsed.features.slice(0, 2).join(' / ')}`)
        }
        if (Array.isArray(parsed.productPrices) && parsed.productPrices.length) {
          const firstPrice = parsed.productPrices[0]
          if (firstPrice && firstPrice.name) {
            parts.push(`可选：${firstPrice.name}${parsed.productPrices.length > 1 ? `等${parsed.productPrices.length}种` : ''}`)
          }
        }

        const summary = parts.join(' · ')
        return summary || '点击进入详情页查看完整商品描述与咨询信息。'
      } catch (error) {
        return description.length > 52 ? `${description.slice(0, 52)}...` : description
      }
    },
    isPremium (star) {
      const score = Number(star)
      return !Number.isNaN(score) && score > 6
    },
    scrollToGoods () {
      if (this.$refs.goodsSection) {
        this.$refs.goodsSection.scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    },
    toChat (num, item) {
      if (item != null) {
        this.$router.push({ name: 'ChatWeb', query: { id: num, user: item.merchant } })
      } else {
        this.$router.push({ name: 'ChatWeb', query: { id: num } })
      }
    },
    back () {
      localStorage.removeItem('usertoken')
      this.$message.success('成功注销')
      this.$router.push('/login')
    },
    goDetail (item) {
      this.$router.push({ name: 'GoodsDetail', query: { id: item.id } })
    },
    account () {
      this.accountDialogVisible = true
    },
    cancelAccount () {
      this.accountDialogVisible = false
    },
    toSetting () {
      this.$router.push('/setting')
    },
    // 检查初始未读状态
    async checkInitialUnread () {
      const usertoken = localStorage.getItem('usertoken')
      try {
        const [res0, res1] = await Promise.all([
          this.$http.get(this.$constant.baseURL + '/chat/getFriend', { usertoken, roleid: 0 }),
          this.$http.get(this.$constant.baseURL + '/chat/getFriend', { usertoken, roleid: 1 })
        ])

        let hasUnread = false
        if (res0.data.code == 200) {
          hasUnread = hasUnread || res0.data.data.some(item => item.unreadnum > 0)
        }
        if (res1.data.code == 200) {
          hasUnread = hasUnread || res1.data.data.some(item => item.unreadnum > 0)
        }

        this.$store.commit('websocket/SET_UNREAD', hasUnread)
      } catch (error) {
        console.error('检查未读消息失败:', error)
      }
    }
  },
  created () {
    this.loadGoodsList()

    const usertoken = localStorage.getItem('usertoken')
    this.$http.get(this.$constant.baseURL + '/chat/getMy', { usertoken }).then((res) => {
      if (res.data.code == 200) {
        this.nick = res.data.data.nick
        this.head = res.data.data.head
        this.role = res.data.data.role
      }
    })

    // 检查初始未读状态
    this.checkInitialUnread()
  }
}
</script>

<style scoped>
.shop-page {
  padding: 26px 30px 30px;
}

.fade-in-top,
.fade-in-up,
.tilt-in-fwd-tr {
  animation-fill-mode: both;
  will-change: transform, opacity;
}

.fade-in-top {
  animation: fade-in-top 0.7s cubic-bezier(0.39, 0.575, 0.565, 1) both;
}

.fade-in-up {
  animation: fade-in-up 0.8s cubic-bezier(0.215, 0.61, 0.355, 1) both;
}

.tilt-in-fwd-tr {
  animation: tilt-in-fwd-tr 0.85s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
}

.delay-1 {
  animation-delay: 0.12s;
}

.top-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 14px 18px;
  margin-bottom: 22px;
  border-radius: 24px;
  border: 1px solid rgba(180, 154, 102, 0.14);
  background: rgba(255,255,255,0.82);
  box-shadow: 0 16px 40px rgba(128, 101, 62, 0.06);
  backdrop-filter: blur(14px);
}

.brand-block {
  display: flex;
  align-items: center;
  gap: 12px;
}

.brand-mark {
  width: 42px;
  height: 42px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  letter-spacing: 0.08em;
  color: #8f621d;
  background: linear-gradient(135deg, rgba(255, 245, 221, 0.96), rgba(248, 236, 210, 0.92));
  border: 1px solid rgba(180, 154, 102, 0.2);
}

.brand-copy strong,
.brand-copy span {
  display: block;
}

.brand-copy strong {
  color: #1f304e;
  font-size: 16px;
}

.brand-copy span {
  color: #7c889e;
  font-size: 12px;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 8px;
}

.nav-link {
  height: 40px;
  padding: 0 16px;
  border-radius: 999px;
  border: 1px solid transparent;
  background: transparent;
  color: #6d7a94;
  font-weight: 700;
  cursor: pointer;
}

.nav-link.active,
.nav-link:hover {
  color: #1f304e;
  background: rgba(247, 239, 225, 0.72);
  border-color: rgba(180, 154, 102, 0.14);
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.icon-entry {
  border: none;
  background: #f8f5ee;
  color: #55627b;
  border-radius: 16px;
  padding: 10px 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: transform 0.28s ease, box-shadow 0.28s ease, background-color 0.28s ease;
}

.icon-entry:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 24px rgba(31, 48, 78, 0.12);
}

.icon-entry.danger {
  background: #fbefef;
  color: #b85d67;
}

.icon-entry {
  position: relative;
}

/* 会话按钮未读红点 */
.unread-dot {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 8px;
  height: 8px;
  background: #ff4d4f;
  border-radius: 50%;
  border: 2px solid #f8f5ee;
}

.icon-badge {
  font-size: 14px;
}

.collection-banner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
  padding: 28px 34px;
  border-radius: 30px;
  background: linear-gradient(135deg, #162033 0%, #22314d 46%, #d5b06f 100%);
  box-shadow: 0 22px 60px rgba(27, 37, 58, 0.22);
  color: #fff;
  position: relative;
  overflow: hidden;
}

.collection-banner::after {
  content: '';
  position: absolute;
  inset: -20% auto auto -10%;
  width: 240px;
  height: 240px;
  background: radial-gradient(circle, rgba(255,255,255,0.18) 0%, rgba(255,255,255,0) 68%);
  animation: float-glow 5.4s ease-in-out infinite;
  pointer-events: none;
}

.collection-kicker {
  font-size: 12px;
  letter-spacing: 0.36em;
  opacity: 0.78;
  margin-bottom: 12px;
}

.collection-title {
  font-size: 34px;
  font-weight: 800;
  margin-bottom: 12px;
}

.collection-desc {
  max-width: 520px;
  color: rgba(255,255,255,0.78);
  line-height: 1.8;
}

.collection-side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 16px;
}

.profile-chip {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 18px;
  background: rgba(255,255,255,0.16);
}

.profile-chip strong,
.profile-chip span {
  display: block;
}

.profile-chip span {
  font-size: 12px;
  color: rgba(255,255,255,0.76);
}

.collection-badge {
  padding: 10px 16px;
  border-radius: 999px;
  background: rgba(255,255,255,0.14);
  border: 1px solid rgba(255,255,255,0.26);
  font-size: 12px;
  letter-spacing: 0.18em;
}

.market-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 28px 0 18px;
  padding: 0 4px;
  gap: 18px;
}

.toolbar-tools {
  display: flex;
  align-items: center;
  gap: 14px;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border-radius: 18px;
  background: rgba(255,255,255,0.82);
  border: 1px solid rgba(180, 154, 102, 0.14);
}

.search-input {
  width: 240px;
  height: 40px;
  border: none;
  outline: none;
  background: transparent;
  color: #21304c;
  font-size: 14px;
}

.search-btn,
.search-reset-btn {
  height: 40px;
  border: none;
  border-radius: 999px;
  padding: 0 16px;
  cursor: pointer;
}

.search-btn {
  background: linear-gradient(135deg, #1b2943, #2f4670);
  color: #fff;
  transition: transform 0.25s ease, box-shadow 0.25s ease, filter 0.25s ease;
}

.search-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 12px 24px rgba(28, 43, 69, 0.2);
  filter: saturate(1.08);
}

.search-reset-btn {
  background: #eef2f8;
  color: #53627b;
}

.toolbar-title {
  font-size: 24px;
  font-weight: 800;
  color: #1f304e;
}

.toolbar-desc {
  margin-top: 6px;
  color: #8290a8;
}

.toolbar-stats {
  min-width: 130px;
  padding: 16px 18px;
  border-radius: 20px;
  background: rgba(255,255,255,0.76);
  border: 1px solid rgba(180, 154, 102, 0.14);
  text-align: center;
}

.toolbar-stats span {
  display: block;
  font-size: 30px;
  font-weight: 800;
  color: #b37b21;
}

.toolbar-stats em {
  font-style: normal;
  color: #8190a9;
}

.goods-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 22px;
}

.single-result-grid {
  grid-template-columns: minmax(320px, 520px);
  justify-content: start;
}

.product-card {
  border-radius: 28px;
  overflow: hidden;
  background: rgba(255,255,255,0.84);
  border: 1px solid rgba(180, 154, 102, 0.14);
  box-shadow: 0 18px 44px rgba(33, 47, 76, 0.08);
  cursor: pointer;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  display: flex;
  flex-direction: column;
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 24px 54px rgba(33, 47, 76, 0.14);
}

.product-cover-wrap {
  position: relative;
  height: 280px;
  overflow: hidden;
}

.premium-badge {
  position: absolute;
  top: 14px;
  left: 14px;
  z-index: 2;
  padding: 6px 12px;
  border-radius: 999px;
  color: #fff8eb;
  font-size: 12px;
  letter-spacing: 0.08em;
  background: linear-gradient(135deg, rgba(164, 113, 22, 0.96), rgba(214, 177, 93, 0.94));
  box-shadow: 0 10px 20px rgba(124, 88, 25, 0.24);
  animation: pulsate-fwd 1.8s ease-in-out infinite both;
}

.product-cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(20, 29, 46, 0.04) 8%, rgba(18, 29, 48, 0.72) 100%);
  color: #fff;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 22px;
}

.product-overlay span {
  font-size: 12px;
  letter-spacing: 0.2em;
  opacity: 0.76;
}

.product-overlay strong {
  margin-top: 8px;
  font-size: 24px;
}

.product-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.product-topline {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.product-tag {
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(247, 239, 225, 0.9);
  color: #9a6a21;
  font-size: 12px;
  font-weight: 700;
}

.product-tag.muted {
  background: rgba(232, 237, 245, 0.92);
  color: #6f7d93;
}

.product-serial {
  color: #95a0b3;
  font-size: 12px;
  letter-spacing: 0.16em;
}

.product-body h3 {
  margin: 0;
  font-size: 22px;
  color: #21304c;
}

.product-summary {
  min-height: 44px;
  margin: 12px 0 18px;
  color: #78859b;
  line-height: 1.7;
}

.product-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-top: auto;
}

.product-price small {
  display: block;
  color: #96a1b2;
  margin-bottom: 6px;
}

.product-price strong {
  font-size: 28px;
  color: #b77718;
}

.buy-btn {
  height: 48px;
  border: none;
  border-radius: 999px;
  background: linear-gradient(135deg, #1b2943, #2f4670);
  color: #fff;
  padding: 0 20px;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: transform 0.25s ease, box-shadow 0.25s ease, gap 0.25s ease;
}

.buy-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 14px 28px rgba(28, 43, 69, 0.24);
  gap: 14px;
}

.buy-btn-arrow {
  font-size: 18px;
}

@keyframes fade-in-top {
  0% {
    transform: translateY(-24px);
    opacity: 0;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes fade-in-up {
  0% {
    transform: translateY(26px);
    opacity: 0;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes tilt-in-fwd-tr {
  0% {
    transform: rotateY(18deg) rotateX(6deg) translateY(-20px) scale(0.96);
    transform-origin: top right;
    opacity: 0;
  }
  100% {
    transform: rotateY(0) rotateX(0) translateY(0) scale(1);
    transform-origin: top right;
    opacity: 1;
  }
}

@keyframes pulsate-fwd {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes float-glow {
  0% {
    transform: translate3d(0, 0, 0) scale(1);
    opacity: 0.7;
  }
  50% {
    transform: translate3d(26px, 18px, 0) scale(1.12);
    opacity: 1;
  }
  100% {
    transform: translate3d(0, 0, 0) scale(1);
    opacity: 0.7;
  }
}

@media (prefers-reduced-motion: reduce) {
  .fade-in-top,
  .fade-in-up,
  .tilt-in-fwd-tr,
  .premium-badge,
  .collection-banner::after {
    animation: none !important;
  }

  .product-card,
  .buy-btn,
  .icon-entry,
  .search-btn {
    transition: none !important;
  }
}

@media (max-width: 1200px) {
  .top-nav,
  .collection-banner,
  .market-toolbar {
    flex-direction: column;
    align-items: flex-start;
  }

  .nav-actions,
  .nav-links {
    flex-wrap: wrap;
  }

  .collection-side {
    align-items: flex-start;
  }
}

@media (max-width: 980px) {
  .top-nav,
  .market-toolbar,
  .toolbar-tools {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    flex-wrap: wrap;
  }

  .search-input {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .shop-page {
    padding: 18px;
  }

  .collection-title {
    font-size: 28px;
  }

  .product-cover-wrap {
    height: 220px;
  }

  .product-bottom {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
