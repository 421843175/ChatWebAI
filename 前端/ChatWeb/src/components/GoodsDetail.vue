<template>
  <div class="detail-page" v-loading="loading">
    <header class="detail-topbar">
      <button class="back-btn" @click="goBack">← 返回商品列表</button>
      <div class="detail-topbar-copy">
        <span>CHATWEB SELECT / GOODS DETAIL</span>
        <strong>商品详情</strong>
      </div>
    </header>

    <section v-if="goods.id" class="detail-hero">
      <div class="detail-preview-panel">
        <div class="detail-preview-frame">
          <img :src="goods.src" :alt="goods.name" class="detail-image">
          <div class="detail-image-badge">CURATED ITEM</div>
        </div>
      </div>

      <div class="detail-info-panel">
        <div class="detail-pill">精品商品 / 一对一咨询</div>
        <h1>{{ displayTitle }}</h1>
        <p class="detail-subtitle">由 {{ goods.merchant }} 发布，支持进入专属会话立即咨询。</p>

        <div class="detail-price-card">
          <span>专属咨询价</span>
          <strong>￥{{ goods.price }}</strong>
        </div>

        <div class="detail-actions">
          <button class="consult-btn" :class="{ disabled: isSelfGoods }" @click="contactMerchant(goods)">{{ isSelfGoods ? '不能咨询自己' : '立即咨询' }}</button>
          <button class="secondary-btn" @click="goBack">继续逛逛</button>
        </div>

        <div class="detail-meta-grid">
          <div class="meta-box">
            <small>商家</small>
            <strong>{{ goods.merchant }}</strong>
          </div>
          <div class="meta-box">
            <small>发布时间</small>
            <strong>{{ formatDate(goods.date) }}</strong>
          </div>
          <div class="meta-box" v-if="displayDescription.brand">
            <small>品牌</small>
            <strong>{{ displayDescription.brand }}</strong>
          </div>
          <div class="meta-box" v-if="displayDescription.productName">
            <small>品名</small>
            <strong>{{ displayDescription.productName }}</strong>
          </div>
        </div>
      </div>
    </section>

    <section v-if="goods.id" class="detail-content-grid">
      <article class="detail-card narrative-card">
        <div class="section-kicker">DESCRIPTION</div>
        <h2>商品亮点</h2>

        <div class="narrative-panel">
          <div class="score-banner">
            <div>
              <small>综合评分</small>
              <div style="display: flex; align-items: center; gap: 8px; margin-top: 4px;">
                <el-rate
                  v-if="goods.star > 0"
                  :value="goods.star / 2"
                  :max="5"
                  disabled
                  show-text
                  :texts="['1分', '2分', '3分', '4分', '5分']"
                  text-color="#ffffff"
                  class="inline-rate">
                </el-rate>
                <strong v-if="goods.star > 0">{{ goods.star }}分</strong>
                <span v-else style="font-size: 18px; color: rgba(255,255,255,0.7);">暂无评分</span>
              </div>
            </div>
            <span v-if="isPremiumGoods">精品臻选</span>
          </div>

          <div v-if="displayDescription.features.length" class="block-section">
            <h3>产品特点</h3>
            <div class="token-list">
              <span v-for="(item, index) in displayDescription.features" :key="`feature-${index}`" class="token-item">{{ item }}</span>
            </div>
          </div>

          <div v-if="displayDescription.scenes.length" class="block-section">
            <h3>使用场景</h3>
            <div class="token-list soft">
              <span v-for="(item, index) in displayDescription.scenes" :key="`scene-${index}`" class="token-item">{{ item }}</span>
            </div>
          </div>

          <div v-if="displayDescription.remark" class="block-section">
            <h3>备注说明</h3>
            <p class="desc-text prominent">{{ displayDescription.remark }}</p>
          </div>

          <div v-if="!hasStructuredContent" class="block-section">
            <h3>商品说明</h3>
            <p class="desc-text prominent">{{ fallbackDescription }}</p>
          </div>
        </div>
      </article>

      <article class="detail-card structure-card">
        <div class="section-kicker">STRUCTURED VIEW</div>
        <h2>商品信息</h2>

        <div class="description-sections">
          <div class="desc-section" v-if="displayDescription.productPrices.length">
            <h3>价格方案</h3>
            <div class="price-plan-list">
              <div class="price-plan-item" v-for="(item, index) in displayDescription.productPrices" :key="`price-${index}`">
                <span>{{ item.name || `方案 ${index + 1}` }}</span>
                <strong>￥{{ item.price }}</strong>
              </div>
            </div>
          </div>

          <div class="desc-section" v-if="displayDescription.specifications.length">
            <h3>规格参数</h3>
            <div class="kv-list">
              <div class="kv-item" v-for="(item, index) in displayDescription.specifications" :key="`spec-${index}`">
                <span>{{ item.key }}</span>
                <strong>{{ item.value }}</strong>
              </div>
            </div>
          </div>

          <div v-if="!hasStructuredContent" class="empty-structure">当前商品暂无结构化描述信息。</div>
        </div>
      </article>

      <article class="detail-card evaluate-card full-width-card">
        <div class="section-kicker">EVALUATIONS</div>
        <h2>商品评价</h2>

        <div v-if="canEvaluate" class="evaluate-form">
          <h3>发表评价</h3>
          <div class="evaluate-form-row">
            <span>你的评分</span>
            <el-rate
              v-model="evaluateForm.rating"
              :max="5"
              allow-half
              show-text
              :texts="['极差', '较差', '一般', '满意', '非常满意']"
              text-color="#b77718">
            </el-rate>
          </div>
          <el-input
            v-model="evaluateForm.comment"
            type="textarea"
            :rows="4"
            maxlength="300"
            show-word-limit
            placeholder="请输入你的使用感受，帮助其他用户了解这个商品。">
          </el-input>
          <button class="consult-btn submit-evaluate-btn" :class="{ disabled: submittingEvaluate }" @click="submitEvaluate">
            {{ submittingEvaluate ? '提交中...' : '提交评价' }}
          </button>
        </div>

        <div v-else class="evaluate-tip">
          仅普通用户可评价商品，商家账号不支持评价自己的或他人的商品。
        </div>

        <div v-if="evaluateList.length" class="evaluate-list">
          <div class="evaluate-item" v-for="(item, index) in evaluateList" :key="`evaluate-${index}`">
            <div class="evaluate-header">
              <strong>{{ item.username || '匿名用户' }}</strong>
              <div class="evaluate-header-right">
                <el-rate
                  :value="item.rating / 2"
                  :max="5"
                  disabled
                  show-text
                  :texts="['1分', '2分', '3分', '4分', '5分']"
                  text-color="#b77718">
                </el-rate>
                <span style="margin-left: 8px; color: #b77718; font-weight: bold;">({{ item.rating }}分)</span>
                <em>{{ item.time || '' }}</em>
              </div>
            </div>
            <p>{{ item.comment }}</p>
          </div>
        </div>
        <div v-else class="empty-structure">当前商品还没有评价，快来成为第一个评价的人吧。</div>
      </article>
    </section>
  </div>
</template>

<script>
export default {
  name: 'GoodsDetail',
  data () {
    return {
      loading: false,
      goods: {},
      parsedDescription: null,
      currentUsername: '',
      currentRole: null,
      evaluateList: [],
      evaluateForm: {
        rating: 0,
        comment: ''
      },
      submittingEvaluate: false
    }
  },
  computed: {
    displayTitle () {
      return this.displayDescription.productName || this.goods.name || '商品详情'
    },
    displayDescription () {
      const parsed = this.parsedDescription || {}
      const specifications = parsed.specifications && typeof parsed.specifications === 'object' && !Array.isArray(parsed.specifications)
        ? Object.keys(parsed.specifications).map(key => ({ key, value: parsed.specifications[key] }))
        : []

      return {
        brand: parsed.brand || '',
        productName: parsed.productName || '',
        productPrices: Array.isArray(parsed.productPrices) ? parsed.productPrices : [],
        features: Array.isArray(parsed.features) ? parsed.features : [],
        specifications,
        scenes: Array.isArray(parsed.scenes) ? parsed.scenes : [],
        remark: parsed.remark || ''
      }
    },
    hasStructuredContent () {
      const data = this.displayDescription
      return Boolean(
        data.brand ||
        data.productName ||
        data.productPrices.length ||
        data.features.length ||
        data.specifications.length ||
        data.scenes.length ||
        data.remark
      )
    },
    fallbackDescription () {
      return this.goods.description || '暂无商品描述'
    },
    isSelfGoods () {
      return Boolean(this.currentUsername && this.goods.merchant && this.currentUsername === this.goods.merchant)
    },
    canEvaluate () {
      return this.currentRole === 2 && !this.isSelfGoods
    },
    isPremiumGoods () {
      const score = Number(this.goods.star)
      return !Number.isNaN(score) && score > 6
    }
  },
  methods: {
    formatDate (date) {
      if (!date) {
        return '暂无'
      }
      return String(date).replace('T', ' ').slice(0, 19)
    },
    parseDescription (description) {
      if (!description) {
        this.parsedDescription = null
        return
      }
      try {
        this.parsedDescription = JSON.parse(description)
      } catch (error) {
        this.parsedDescription = null
      }
    },
    parseEvaluate (evaluate) {
      if (!evaluate) {
        this.evaluateList = []
        return
      }

      if (Array.isArray(evaluate)) {
        this.evaluateList = evaluate.map(item => this.normalizeEvaluateItem(item)).filter(Boolean)
        return
      }

      if (typeof evaluate === 'object') {
        this.evaluateList = [evaluate].map(item => this.normalizeEvaluateItem(item)).filter(Boolean)
        return
      }

      try {
        const parsed = JSON.parse(evaluate)
        const list = Array.isArray(parsed) ? parsed : [parsed]
        this.evaluateList = list.map(item => this.normalizeEvaluateItem(item)).filter(Boolean)
      } catch (error) {
        this.evaluateList = []
      }
    },
    normalizeEvaluateItem (item) {
      if (!item || typeof item !== 'object') {
        return null
      }
      return {
        username: item.username || item.user || '匿名用户',
        rating: item.rating != null ? item.rating : item.score,
        comment: item.comment || item.content || '',
        time: this.formatDate(item.time || item.createTime || item.date)
      }
    },
    async loadEvaluateListByMerchant () {
      if (!this.goods.merchant) {
        return
      }
      try {
        const res = await this.$http.get(this.$constant.baseURL + '/evaluate/listByMerchant', {
          merchant: this.goods.merchant
        })
        if (res.data.code === 200 && Array.isArray(res.data.data) && res.data.data.length) {
          this.evaluateList = res.data.data.map(item => this.normalizeEvaluateItem(item)).filter(Boolean)
        }
      } catch (error) {
      }
    },
    async loadCurrentUser () {
      try {
        const usertoken = localStorage.getItem('usertoken')
        if (!usertoken) {
          return
        }
        const res = await this.$http.get(this.$constant.baseURL + '/chat/getMy', { usertoken })
        if (res.data.code === 200 && res.data.data) {
          this.currentUsername = res.data.data.username || ''
          this.currentRole = res.data.data.role
        }
      } catch (error) {
        this.currentUsername = ''
        this.currentRole = null
      }
    },
    async loadDetail () {
      const id = this.$route.query.id
      if (!id) {
        this.$message.error('缺少商品ID')
        this.goBack()
        return
      }
      this.loading = true
      try {
        const res = await this.$http.get(this.$constant.baseURL + '/goods/detail', { id })
        if (res.data.code === 200) {
          this.goods = res.data.data || {}
          console.log('goods detail data:', this.goods)
          this.parseDescription(this.goods.description)
          this.parseEvaluate(this.goods.evaluate)
          await this.loadEvaluateListByMerchant()
        }
      } catch (error) {
        this.$message.error(error.message || '获取商品详情失败')
        this.goBack()
      } finally {
        this.loading = false
      }
    },
    async contactMerchant (item) {
      if (this.isSelfGoods) {
        this.$message.warning('不能自己咨询自己')
        return
      }
      try {
        const usertoken = localStorage.getItem('usertoken')
        const res = await this.$http.post(this.$constant.baseURL + '/goods/toChat', { usertoken, item })
        if (res.data.code === 200) {
          this.$router.push({ name: 'ChatWeb', query: { id: 1, user: item.merchant } })
        }
      } catch (error) {
        this.$message.error(error.message || '进入会话失败')
      }
    },
    async submitEvaluate () {
      if (!this.canEvaluate) {
        this.$message.warning('当前账号不可评价该商品')
        return
      }
      if (!this.evaluateForm.rating) {
        this.$message.warning('请选择评分')
        return
      }
      if (!this.evaluateForm.comment.trim()) {
        this.$message.warning('请输入评价内容')
        return
      }

      this.submittingEvaluate = true
      try {
        const params = {
          goodsId: this.goods.id,
          merchant: this.goods.merchant,
          username: localStorage.getItem('usertoken'),
          score: this.evaluateForm.rating * 2,  // 5颗心=10分，评分乘以2转换
          content: this.evaluateForm.comment.trim()
        }
        const res = await this.$http.post(this.$constant.baseURL + '/evaluate/submit', params)
        if (res.data.code === 200) {
          this.$message.success('评价提交成功')
          this.evaluateForm.rating = 0
          this.evaluateForm.comment = ''
          this.loadDetail()
        } else {
          this.$message.error(res.data.msg || '评价提交失败')
        }
      } catch (error) {
        this.$message.error(error.message || '评价提交失败')
      } finally {
        this.submittingEvaluate = false
      }
    },
    goBack () {
      this.$router.push('/')
    }
  },
  created () {
    this.loadCurrentUser()
    this.loadDetail()
  }
}
</script>

<style scoped>
.detail-page {
  min-height: 100vh;
  padding: 26px 30px 40px;
  background:
    radial-gradient(circle at top left, rgba(213, 176, 111, 0.16), transparent 24%),
    linear-gradient(180deg, #f6f1e7 0%, #eef2f7 42%, #f6f7fb 100%);
}

.detail-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 24px;
  padding: 16px 18px;
  border-radius: 24px;
  background: rgba(255,255,255,0.82);
  border: 1px solid rgba(180, 154, 102, 0.16);
  box-shadow: 0 18px 44px rgba(31, 48, 78, 0.08);
}

.back-btn,
.secondary-btn {
  height: 44px;
  padding: 0 18px;
  border-radius: 999px;
  border: 1px solid rgba(32, 49, 77, 0.16);
  background: rgba(255,255,255,0.88);
  color: #20314d;
  cursor: pointer;
}

.detail-topbar-copy span {
  display: block;
  font-size: 12px;
  color: #8c96a9;
  letter-spacing: 0.24em;
}

.detail-topbar-copy strong {
  display: block;
  margin-top: 6px;
  font-size: 22px;
  color: #20314d;
}

.detail-hero {
  display: grid;
  grid-template-columns: 1.08fr 0.92fr;
  gap: 24px;
}

.detail-preview-panel,
.detail-info-panel,
.detail-card {
  border-radius: 30px;
  background: rgba(255,255,255,0.84);
  border: 1px solid rgba(180, 154, 102, 0.14);
  box-shadow: 0 24px 60px rgba(31, 48, 78, 0.08);
}

.detail-preview-panel {
  padding: 24px;
}

.detail-preview-frame {
  position: relative;
  min-height: 560px;
  border-radius: 28px;
  overflow: hidden;
  background: linear-gradient(135deg, #192338, #293b5d 60%, #d5b06f);
}

.detail-image {
  width: 100%;
  height: 100%;
  min-height: 560px;
  object-fit: cover;
  mix-blend-mode: screen;
}

.detail-image-badge {
  position: absolute;
  left: 20px;
  bottom: 20px;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255,255,255,0.14);
  color: #fff;
  font-size: 12px;
  letter-spacing: 0.2em;
  border: 1px solid rgba(255,255,255,0.24);
}

.detail-info-panel {
  padding: 30px;
  display: flex;
  flex-direction: column;
}

.detail-pill {
  align-self: flex-start;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(247, 239, 225, 0.9);
  color: #9d6d22;
  font-size: 12px;
  letter-spacing: 0.16em;
}

.detail-info-panel h1 {
  margin: 20px 0 10px;
  font-size: 42px;
  color: #1f304e;
}

.detail-subtitle {
  margin: 0;
  color: #7d899d;
  line-height: 1.8;
}

.detail-price-card {
  margin-top: 28px;
  padding: 24px 26px;
  border-radius: 24px;
  background: linear-gradient(135deg, #1b2943, #2f4670);
  color: #fff;
}

.detail-price-card span {
  display: block;
  font-size: 13px;
  letter-spacing: 0.18em;
  opacity: 0.72;
}

.detail-price-card strong {
  display: block;
  margin-top: 12px;
  font-size: 42px;
}

.detail-actions {
  display: flex;
  gap: 14px;
  margin-top: 24px;
}

.consult-btn {
  flex: 1;
  height: 54px;
  border: none;
  border-radius: 999px;
  background: linear-gradient(135deg, #d4a14a, #b77718);
  color: #fff;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 16px 30px rgba(183, 119, 24, 0.28);
}

.consult-btn.disabled {
  background: linear-gradient(135deg, #b8becb, #9097a8);
  box-shadow: none;
}

.detail-meta-grid {
  margin-top: 24px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.meta-box {
  padding: 18px;
  border-radius: 20px;
  background: #f5f7fb;
}

.meta-box small {
  display: block;
  color: #8b95a8;
}

.meta-box strong {
  display: block;
  margin-top: 8px;
  color: #1f304e;
  word-break: break-all;
}

.detail-content-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-top: 24px;
}

.detail-card {
  padding: 28px;
}

.full-width-card {
  grid-column: 1 / -1;
}

.section-kicker {
  font-size: 12px;
  letter-spacing: 0.26em;
  color: #a58a56;
}

.detail-card h2 {
  margin: 12px 0 18px;
  font-size: 28px;
  color: #1f304e;
}

.narrative-panel {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.score-banner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 18px 20px;
  border-radius: 22px;
  background: linear-gradient(135deg, rgba(27, 41, 67, 0.95), rgba(183, 119, 24, 0.92));
  color: #fff;
}

.score-banner small {
  display: block;
  opacity: 0.76;
}

.score-banner strong {
  display: block;
  margin-top: 6px;
  font-size: 34px;
}

.score-banner span {
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.22);
  font-size: 12px;
  letter-spacing: 0.14em;
}

.block-section {
  padding: 20px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(27, 41, 67, 0.03), rgba(183, 119, 24, 0.05));
}

.block-section h3,
.desc-section h3 {
  margin: 0 0 14px;
  color: #21304c;
  font-size: 18px;
}

.description-sections {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.desc-section {
  padding: 20px;
  border-radius: 22px;
  background: #f7f9fc;
}

.token-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.token-list.soft .token-item {
  background: rgba(31, 48, 78, 0.08);
  color: #43516b;
}

.token-item {
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(213, 176, 111, 0.16);
  color: #99681f;
}

.price-plan-list {
  display: grid;
  gap: 12px;
}

.price-plan-item,
.kv-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 0;
  border-bottom: 1px solid rgba(32, 49, 77, 0.08);
}

.price-plan-item:last-child,
.kv-item:last-child {
  border-bottom: none;
}

.price-plan-item span,
.kv-item span {
  color: #8592a7;
}

.price-plan-item strong,
.kv-item strong {
  color: #1f304e;
  text-align: right;
}

.desc-text,
.empty-structure {
  margin: 0;
  color: #7b8699;
  line-height: 1.8;
}

.desc-text.prominent {
  color: #43516b;
}

.evaluate-form,
.evaluate-item,
.evaluate-tip {
  padding: 20px;
  border-radius: 22px;
  background: #f7f9fc;
}

.evaluate-form h3 {
  margin: 0 0 16px;
  color: #21304c;
}

.evaluate-form-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
  color: #6f7d93;
}

.submit-evaluate-btn {
  width: 100%;
  margin-top: 16px;
}

.evaluate-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 18px;
}

.evaluate-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.evaluate-header strong {
  color: #1f304e;
}

.evaluate-header-right {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #8a97ab;
  font-style: normal;
}

.evaluate-rating {
  color: #b77718;
  font-weight: 700;
}

.evaluate-item p {
  margin: 12px 0 0;
  color: #56657d;
  line-height: 1.8;
}

/* 禁用评价列表中星星的悬停抖动效果 */
::v-deep .evaluate-header-right .el-rate__item {
  cursor: default;
}
::v-deep .evaluate-header-right .el-rate__star {
  transition: none !important;
}
::v-deep .evaluate-header-right .el-rate__star:hover {
  transform: none !important;
}

/* 禁用综合评分区域星星的悬停抖动效果 */
::v-deep .score-banner .el-rate__star {
  transition: none !important;
}
::v-deep .score-banner .el-rate__star:hover {
  transform: none !important;
}

@media (max-width: 1100px) {
  .detail-hero,
  .detail-content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .detail-page {
    padding: 18px;
  }

  .detail-topbar,
  .detail-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .detail-info-panel h1 {
    font-size: 30px;
  }

  .detail-meta-grid {
    grid-template-columns: 1fr;
  }

  .detail-preview-frame,
  .detail-image {
    min-height: 360px;
  }
}
</style>
