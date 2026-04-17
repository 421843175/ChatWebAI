<template>
    <div class="question-manage">
      <!-- 操作栏 -->
      <div class="operation-bar">
        <el-button 
          type="primary" 
          icon="el-icon-plus"
          @click="openEditDialog(null)"
        >新增问答</el-button>
      </div>
  
      <!-- 数据表格 -->
      <el-table 
        :data="tableData"
        v-loading="loading"
        style="width: 100%"
      >
        <el-table-column prop="question" label="问题" width="300"></el-table-column>
        <el-table-column prop="answer" label="回答"></el-table-column>
        <el-table-column prop="prority" label="优先级" width="100">
          <template slot-scope="{row}">
            <el-tag :type="row.prority > 0 ? 'success' : 'info'">
              {{ row.prority || 0 }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template slot-scope="{row}">
            <el-button 
              size="mini"
              @click="openEditDialog(row)"
            >编辑</el-button>
            <el-button 
              size="mini" 
              type="danger"
              @click="handleDelete(row.id)"
            >删除</el-button>
          </template>
        </el-table-column>
      </el-table>
  
      <!-- 编辑弹窗 -->
      <el-dialog
        :title="editForm.id ? '编辑问答' : '新增问答'"
        :visible.sync="editVisible"
        width="600px"
        append-to-body
      >
        <el-form :model="editForm" label-width="80px">
          <el-form-item label="问题" required>
            <el-input 
              v-model="editForm.question" 
              placeholder="请输入问题"
              maxlength="100"
              show-word-limit
            ></el-input>
          </el-form-item>
  
          <el-form-item label="回答" required>
            <el-input
              type="textarea"
              :rows="4"
              v-model="editForm.answer"
              placeholder="请输入回答内容"
              maxlength="500"
              show-word-limit
            ></el-input>
          </el-form-item>
  
          <el-form-item label="优先级">
            <el-input-number 
              v-model="editForm.prority"
              :min="0" 
              :max="99"
              label="优先级越高排序越靠前"
            ></el-input-number>
          </el-form-item>
        </el-form>
  
        <span slot="footer">
          <el-button @click="editVisible = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="submitEdit"
            :loading="submitting"
          >确 定</el-button>
        </span>
      </el-dialog>
    </div>
  </template>
  
  <script>
  export default {
    name: "Question",
    data() {
      return {
        loading: false,
        tableData: [],
        editVisible: false,
        submitting: false,
        editForm: {
          id: null,
          question: '',
          answer: '',
          prority: 0
        }
      }
    },
    created() {
      this.loadData();
    },
    methods: {
      // 加载数据
      async loadData() {
        this.loading = true;
        try {
          const res = await this.$http.get(this.$constant.baseURL +'/reply/list', {
          
              usertoken: localStorage.getItem('usertoken')
            
          });
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
          console.log("params:",params)
          const res = await this.$http.post(this.$constant.baseURL +'/reply/save', params);
          
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
          
          const res = await this.$http.get(this.$constant.baseURL +'/reply/delete', {
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