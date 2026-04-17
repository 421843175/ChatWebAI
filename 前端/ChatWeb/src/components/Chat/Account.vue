<template>
    <!-- 新增账号管理对话框 -->
    <el-dialog
      title="账号管理"
      :visible="visible"
      width="40%"
      append-to-body
      @close="handleClose">
      
      <!-- 头像上传 -->
      <div class="avatar-section">
        <el-upload
          class="avatar-uploader"
          :action="this.$constant.baseURL +'/upload/avatar'"
          :show-file-list="false"
          :on-success="handleAvatarSuccess"
          :before-upload="beforeAvatarUpload">
          <img v-if="form.avatar" :src="form.avatar" class="avatar">
          <i v-else class="el-icon-plus avatar-uploader-icon"></i>
        </el-upload>
        <div class="upload-tip">支持JPG/PNG格式，大小不超过2MB</div>
      </div>
  
      <!-- 表单部分 -->
      <el-form 
        :model="form" 
        :rules="rules" 
        ref="accountForm" 
        label-width="100px">
        
        <!-- 昵称修改 -->
        <el-form-item label="用户昵称" prop="nick">
          <el-input 
            v-model="form.nick" 
            placeholder="请输入新昵称"
            maxlength="20"
            show-word-limit>
          </el-input>
        </el-form-item>
  
        <!-- 密码修改 -->
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            type="password"
            v-model="form.newPassword"
            autocomplete="new-password"
            placeholder="6-20位字母/数字组合">
          </el-input>
        </el-form-item>
  
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            type="password"
            v-model="form.confirmPassword"
            autocomplete="new-password">
          </el-input>
        </el-form-item>
  
        <!-- 原密码验证 -->
        <el-form-item label="原密码" prop="oldPassword" v-if="form.newPassword">
          <el-input
            type="password"
            v-model="form.oldPassword"
            autocomplete="current-password">
          </el-input>
        </el-form-item>
  
        <div class="dialog-footer">
          <el-button @click="handleClose">取消</el-button>
          <el-button 
            type="primary" 
            @click="submitForm"
            :loading="submitting">
            {{ submitting ? '提交中...' : '确认修改' }}
          </el-button>
        </div>
      </el-form>
    </el-dialog>
  </template>
  
  <script>
  export default {
    name:"Acccount",
    data() {
      // 密码验证规则
      const validatePass = (rule, value, callback) => {
        if (value !== this.form.confirmPassword) {
          callback(new Error('两次输入密码不一致!'));
        } else {
          callback();
        }
      };
      
      return {
        submitting: false,
        form: {
          avatar: '',
          nick: '',
          newPassword: '',
          confirmPassword: '',
          oldPassword: ''
        },
        rules: {
          nick: [
            {  message: '昵称不能为空', trigger: 'blur' },
            { min: 2, max: 20, message: '长度在2到20个字符', trigger: 'blur' }
          ],
          newPassword: [
            { pattern: /^.{6,20}$/, 
                message: '密码长度为6-20位'}
          ],
          confirmPassword: [
            { validator: validatePass, trigger: 'blur' }
          ],
          oldPassword: [
            {  message: '需要原密码验证', trigger: 'blur' }
          ]
        }
      };
    },
    props:['visible'],
    methods: {
      // 打开账号管理对话框
      account() {
        this.getUserInfo();
 
      },
      
      // 获取用户当前信息
      async getUserInfo() {
        try {
          const res = await this.$http.get('/user/info');
          this.form.nick = res.data.nick;
          this.form.avatar = res.data.avatar;
        } catch (error) {
          this.$message.error('获取用户信息失败');
        }
      },
  
      // 头像上传处理
      handleAvatarSuccess(res) {
                if (res.code === 200) {
                this.form.avatar = res.data;
            } else {
                this.$message.error(res.msg);
            }
      },
  
      beforeAvatarUpload(file) {
        const isImage = ['image/jpeg', 'image/png'].includes(file.type);
        const isLt2M = file.size / 1024 / 1024 < 2;
  
        if (!isImage) {
          this.$message.error('只能上传JPG/PNG格式!');
        }
        if (!isLt2M) {
          this.$message.error('头像大小不能超过2MB!');
        }
        return isImage && isLt2M;
      },
  
      // 提交表单
      async submitForm() {
        this.$refs.accountForm.validate(async valid => {
          if (valid) {
            this.submitting = true;
            try {
              const params = {
                usertoken: localStorage.getItem("usertoken"),
                nick: this.form.nick,
                avatar: this.form.avatar
              };
  
              // 如果有密码修改
              if (this.form.newPassword) {
                params.oldPassword = this.$common.encrypt(this.form.oldPassword.trim());
                params.newPassword = this.$common.encrypt(this.form.newPassword.trim());
              }
  
              await this.$http.put(this.$constant.baseURL +'/user/update', params);
              this.$message.success('修改成功！');
              this.$emit("cancelAccount");
              this.updateUserInfo(); // 更新全局用户信息
            } catch (error) {
              this.handleError(error);
            } finally {
              this.submitting = false;
            }
          }
        });
      },
  
      handleError(error) {

        console.log("handlerError:",error)
  // 安全访问嵌套属性
  const response = error && error.response;
  const data = response && response.data;
  const serverMsg = data && data.message;
  
  // 使用逻辑或提供默认值
  const msg = serverMsg || '修改失败';
  
  if (error.response && error.response.status === 401) {
    this.$message.error('原密码错误');
  } else {
    this.$message.error(msg);
  }
    },
  
      // 重置表单
      resetForm() {
        this.$refs.accountForm.resetFields();
        this.form.avatar = '';
      },
  
      // 更新全局用户信息
      updateUserInfo() {
        this.$store.dispatch('user/fetchUserInfo');
      },
      handleClose(){
        this.$emit("close");
      }
    }
  };
  </script>
  
  <style scoped>
  .avatar-section {
    text-align: center;
    margin-bottom: 20px;
  }
  
  .avatar-uploader {
    display: inline-block;
    border: 2px dashed #ddd;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
  }
  
  .avatar-uploader:hover {
    border-color: #409EFF;
  }
  
  .avatar-uploader-icon {
    font-size: 28px;
    color: #8c939d;
    width: 120px;
    height: 120px;
    line-height: 120px;
    text-align: center;
  }
  
  .avatar {
    width: 120px;
    height: 120px;
    display: block;
  }
  
  .upload-tip {
    font-size: 12px;
    color: #909399;
    margin-top: 10px;
  }
  
  .dialog-footer {
    text-align: right;
    margin-top: 30px;
  }
  </style>