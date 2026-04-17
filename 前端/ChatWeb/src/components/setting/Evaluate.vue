<template>
  <div class="question-manage">
    <!-- 操作栏 -->

    <!-- 数据表格 -->

    <div class="statistics" v-if="tableData.length > 0">
      平均评级：{{ averageScore }} ({{ (averageScore / 2).toFixed(1) }}颗心)
    </div>



    <el-table :data="tableData" v-loading="loading" style="width: 100%">
      <el-table-column prop="score" label="评级" width="300"></el-table-column>
      <el-table-column prop="content" label="评价" width="100"></el-table-column>

      <el-table-column prop="username" label="用户" width="100"></el-table-column>
      <el-table-column prop="createTime" label="时间" :formatter="formatDateTime"></el-table-column>
    </el-table>


  </div>
</template>

<script>
export default {
  name: "Evaluate",
  data() {
    return {
      loading: false,
      tableData: [],
      editVisible: false,
      submitting: false
    }
  },
  created() {
    this.loadData();
  },
  computed:{
    averageScore() {
      const validScores = this.tableData
        .map(item => parseFloat(item.score))
        .filter(score => !isNaN(score))
      
      if (validScores.length === 0) return '暂无数据'
      
      const average = validScores.reduce((acc, cur) => acc + cur, 0) / validScores.length
      return average.toFixed(2)  // 保留两位小数
    }
  
  },
  methods: {
    // 加载数据
    async loadData() {
      this.loading = true;
      try {
        const res = await this.$http.get(this.$constant.baseURL + '/evaluate/list', {

          usertoken: localStorage.getItem('usertoken')

        });
        console.log("res=", res)
        if (res.data.code === 200) {

          this.tableData = res.data.data;
        }
      } finally {
        this.loading = false;
      }
    },

    // 打开编辑窗口
    openEditDialog(row) {
      this.editForm = row ? { ...row } : {
        id: null,
        question: '',
        answer: '',
        prority: 0
      };
      this.editVisible = true;
    },

    // 提交编辑
    async submitEdit() {
      if (!this.validateForm()) return;

      this.submitting = true;
      try {
        const params = {
          ...this.editForm,
          usertoken: localStorage.getItem('usertoken')
        };
        console.log("params:", params)
        const res = await this.$http.post(this.$constant.baseURL + '/reply/save', params);

        if (res.data.code === 200) {
          this.$message.success('保存成功');
          this.editVisible = false;
          this.loadData();
        }
      } finally {
        this.submitting = false;
      }
    },

    // 删除操作
    async handleDelete(id) {
      try {
        await this.$confirm('确认删除该问答？删除后不可恢复', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        });

        const res = await this.$http.get(this.$constant.baseURL + '/reply/delete', {
          id: id,
          usertoken: localStorage.getItem('usertoken')
        });

        if (res.data.code === 200) {
          this.$message.success('删除成功');
          this.loadData();
        }
      } catch (error) {
        // 取消删除时不处理
      }
    },

    // 表单验证
    validateForm() {
      if (!this.editForm.question.trim()) {
        this.$message.warning('请填写问题');
        return false;
      }
      if (!this.editForm.answer.trim()) {
        this.$message.warning('请填写回答');
        return false;
      }
      return true;
    },
    formatDateTime(row, column, cellValue) {
      if (!cellValue) return '';
      // 处理iOS兼容性
      const parsedDate = new Date(cellValue.replace(/-/g, '/'));
      const date = isNaN(parsedDate) ? new Date(cellValue) : parsedDate;

      if (isNaN(date)) return cellValue;

      const pad = n => n.toString().padStart(2, '0');
      return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
    }
  }
}
</script>

<style scoped>
.question-manage {
  padding: 20px;
  background: #fff;
  border-radius: 4px;
}

.operation-bar {
  margin-bottom: 20px;
}

.el-table {
  margin-top: 15px;
}

.el-textarea__inner {
  resize: vertical;
}
</style>