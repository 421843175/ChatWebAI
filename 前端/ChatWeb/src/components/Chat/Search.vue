<template>
  <div class="search-box">
        <el-input
          placeholder="搜索最近联系人"
          prefix-icon="el-icon-search"
          v-model="searchinput"
          class="searchInput"
          @input="handleSearch"
      clearable>
        </el-input>

      <div v-if="searchResults.length > 0" class="search-results">
      <div v-for="(item, index) in searchResults" :key="index" class="search-item" @click="selectFriend(item)">
          <el-avatar :src="item.head" size="small"></el-avatar>
        <div class="search-content">
          <span class="username">{{ item.nickname }}</span>
          <span class="last-msg">
            {{ item.messageEnd ? (item.messageEnd.length > 12 ? item.messageEnd.slice(0, 12) + '...' : item.messageEnd) : '暂无聊天记录' }}
          </span>
        </div>
      </div>
      </div>

    <div v-else-if="searchinput" class="empty-tips">未找到匹配的联系人</div>
    </div>
  </template>
  
  <script>
  export default {
  name: 'Search',
  data () {
      return {
      searchinput: '',
        searchResults: [],
        searchTimer: null
      }
    },
    methods: {
    handleSearch () {
      clearTimeout(this.searchTimer)
        this.searchTimer = setTimeout(() => {
          if (this.searchinput.trim()) {
          this.$http.get(this.$constant.baseURL + '/chat/searchFriend', {
                keyword: this.searchinput,
                usertoken: localStorage.getItem('usertoken')
            }).then(res => {
              if (res.data.code === 200) {
              this.searchResults = res.data.data
              }
          })
          } else {
          this.searchResults = []
          }
      }, 300)
      },
    selectFriend (item) {
      this.$emit('friendselected', item)
      this.searchinput = ''
      this.searchResults = []
      }
    }
  }
  </script>
  
  <style scoped>
.search-box {
  position: relative;
}

  .search-results {
  margin-top: 12px;
  border-radius: 18px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.04);
  overflow: hidden;
  }
  
  .search-item {
  padding: 12px 14px;
    cursor: pointer;
    display: flex;
    align-items: center;
  gap: 12px;
  transition: background-color 0.24s ease;
  }
  
  .search-item:hover {
  background-color: rgba(255,255,255,0.06);
}

.search-content {
  display: flex;
  flex-direction: column;
  min-width: 0;
  }
  
  .username {
  color: var(--text);
  font-weight: 700;
  }
  
.last-msg,
.empty-tips {
  color: var(--muted);
    font-size: 12px;
  }
  
  .empty-tips {
    text-align: center;
  padding: 18px 0 8px;
}

::v-deep .el-input__inner {
  height: 46px;
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.04);
  color: var(--text);
  }
  </style>
