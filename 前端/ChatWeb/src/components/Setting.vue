<template>
  <div class="setting-page">
    <div class="setting-sidebar">
      <div class="setting-brand">
        <span>SELLER CONSOLE</span>
        <h2>卖家工作台</h2>
        <p>统一管理商品、问答、AI 形象与服务评价。</p>
      </div>

      <el-menu default-active="1" class="seller-menu" @select="handleMenuSelect">
          <el-menu-item index="1">
            <i class="el-icon-goods"></i>
            <span>商品管理</span>
          </el-menu-item>
          <el-menu-item index="2">
            <i class="el-icon-question"></i>
            <span>问题管理</span>
          </el-menu-item>
          <el-menu-item index="3">
            <i class="el-icon-user-solid"></i>
            <span>AI形象设置</span>
          </el-menu-item>
          <el-menu-item index="4">
            <i class="el-icon-s-home"></i>
            <span>评价中心</span>
          </el-menu-item>
          <el-menu-item index="5">
          <i class="el-icon-back"></i>
            <span>返回主页</span>
          </el-menu-item>
        </el-menu>
      </div>
  
    <div class="setting-content">
      <div class="content-head">
        <div>
          <div class="content-kicker">WORKSPACE</div>
          <h1>{{ menuTitle }}</h1>
        </div>
      </div>

      <div v-show="activeMenu === '1'" class="content-panel">
            <GoodsManage></GoodsManage>
        </div>
      <div v-show="activeMenu === '2'" class="content-panel">
            <Question></Question>
        </div>
      <div v-show="activeMenu === '3'" class="content-panel">
                <Clothes></Clothes>
        </div>
      <div v-show="activeMenu === '4'" class="content-panel">
                <Evaluate></Evaluate>
        </div>
      </div>
    </div>
  </template>
  
  <script>
import GoodsManage from './setting/GoodsManage.vue'
import Question from './setting/Question.vue'
import Clothes from './Clothes.vue'
import Evaluate from './setting/Evaluate.vue'

  export default {
  components: {
        GoodsManage,
        Question,
        Clothes,
        Evaluate
  },
  data () {
    return {
      activeMenu: '1'
    }
  },
  computed: {
    menuTitle () {
      const map = {
        1: '商品管理',
        2: '问题管理',
        3: 'AI 形象设置',
        4: '评价中心'
      }
      return map[this.activeMenu] || '卖家工作台'
    }
  },
  methods: {
    handleMenuSelect (index) {
      if (index == 5) {
        this.$router.push('/')
        return
      }
      this.activeMenu = index
    }
    }
  }
  </script>
  
<style scoped>
.setting-page {
    min-height: 100vh;
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 18px;
  padding: 18px;
  }
  
.setting-sidebar,
.setting-content {
  border-radius: 28px;
  border: 1px solid rgba(115,140,189,0.14);
  background: rgba(255, 255, 255, 0.82);
  box-shadow: var(--shadow);
  backdrop-filter: blur(18px);
}

.setting-sidebar {
  padding: 22px;
}

.setting-brand span {
  color: var(--brand);
  font-size: 12px;
  letter-spacing: 0.22em;
}

.setting-brand h2 {
  margin: 14px 0 10px;
  font-size: 30px;
  color: #203452;
  }
  
.setting-brand p {
  margin: 0 0 20px;
  color: var(--muted);
  line-height: 1.8;
}

.setting-content {
  padding: 24px;
  }
  
.content-head {
  margin-bottom: 18px;
}

.content-kicker {
  color: var(--muted);
  font-size: 12px;
  letter-spacing: 0.18em;
  margin-bottom: 8px;
}

.content-head h1 {
  margin: 0;
  font-size: 34px;
  color: #223454;
  }
  
.content-panel {
  border-radius: 24px;
  border: 1px solid rgba(115,140,189,0.12);
  background: rgba(255,255,255,0.8);
    padding: 20px;
  min-height: calc(100vh - 140px);
  }
  
::v-deep .seller-menu {
  border-right: 0;
  background: transparent;
}

::v-deep .seller-menu .el-menu-item {
  margin-bottom: 10px;
  border-radius: 16px;
  color: var(--muted);
  background: transparent;
  }
  
::v-deep .seller-menu .el-menu-item.is-active {
  color: #253654;
  background: linear-gradient(135deg, rgba(62,207,142,0.12), rgba(111,140,255,0.1));
  }
  
@media (max-width: 920px) {
  .setting-page {
    grid-template-columns: 1fr;
  }
  }
  </style>
