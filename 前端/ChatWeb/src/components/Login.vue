<template>
  <div class="login-page">
    <div class="auth-ambient auth-ambient-left"></div>
    <div class="auth-ambient auth-ambient-right"></div>

    <div class="auth-shell">
      <div class="auth-brand">
        <div class="brand-badge">ChatWeb · AI COMMERCE</div>
        <h1>让购物更有未来感</h1>
        <p>
          融入AI和库,让购物更加明晰
        </p>

        <div class="brand-cards">
          <div class="brand-card">
            <span class="card-kicker">智能客服</span>
            <strong>AI + 人工无缝切换</strong>
            <em>更像真实的业务后台，而不是朴素表单页。</em>
          </div>
          <div class="brand-card">
            <span class="card-kicker">商品交互</span>
            <strong>从购买到咨询一体化</strong>
            <em>商品、对话、角色形象统一在同一套体验里。</em>
          </div>
        </div>
      </div>

      <div class="auth-panel">
        <div class="panel-top">
          <div>
            <div class="panel-kicker">WELCOME BACK</div>
            <h2>{{ disfiex === 0 ? '登录你的账户' : '创建新的账户' }}</h2>
          </div>
          <div class="switch-pill">
            <button :class="['switch-btn', { active: disfiex === 0 }]" @click="Signup">登录</button>
            <button :class="['switch-btn', { active: disfiex === 1 }]" @click="Signin">注册</button>
          </div>
        </div>

        <el-form ref="form" :model="form" :rules="rules" label-position="top" class="auth-form">
          <template v-if="disfiex === 0">
            <div class="form-grid single">
              <el-form-item prop="username" label="账号">
                <el-input v-model="form.username" placeholder="请输入账号"></el-input>
                    </el-form-item>
              <el-form-item prop="password" label="密码">
                <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password></el-input>
                    </el-form-item>
                </div>

            <div class="auth-actions">
              <el-button class="primary-btn" @click="submitLogin">立即登录</el-button>
              <span class="action-tip">还没有账户？<b @click="Signin">现在注册</b></span>
            </div>
          </template>
         
          <template v-else>
            <div class="role-group">
              <div class="role-title">选择你的身份</div>
              <div class="role-options">
                <label class="role-card" :class="{ active: form.role === '1' }">
                  <input v-model="form.role" type="radio" value="1">
                  <span class="role-name">卖家</span>
                  <small>管理商品、处理咨询与评价</small>
                </label>
                <label class="role-card" :class="{ active: form.role === '2' }">
                  <input v-model="form.role" type="radio" value="2">
                  <span class="role-name">买家</span>
                  <small>浏览商品、咨询商家、完成购买</small>
                </label>
              </div>
                    </div>
                    
            <div class="form-grid">
              <el-form-item label="昵称">
                <el-input v-model="form.nick" placeholder="请输入昵称"></el-input>
                    </el-form-item>
              <el-form-item prop="username" label="账号">
                <el-input v-model="form.username" placeholder="请输入账号"></el-input>
                    </el-form-item>
                    <el-form-item prop="password" label="密码">
                <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password></el-input>
                    </el-form-item>
                    <el-form-item prop="repasswd" label="确认密码">
                <el-input v-model="form.repasswd" type="password" placeholder="请再次输入密码" show-password></el-input>
                    </el-form-item>
                </div>

            <div class="auth-actions">
              <el-button class="primary-btn" @click="submitRegister">创建账户</el-button>
              <span class="action-tip">已经有账户？<b @click="Signup">直接登录</b></span>
                </div>
          </template>
        </el-form>
        </div>
</div>
    </div>
</template>

<script>
export default {
    data () {
    const validatePass2 = (rule, value, callback) => {
      if (this.disfiex === 0) {
        callback()
        return
      }
        if (value === '') {
        callback(new Error('请再次输入密码'))
        } else if (value !== this.form.password) {
        callback(new Error('两次输入密码不一致'))
        } else {
        callback()
      }
        }

        return {
            disfiex: 0,
      form: {
        nick: '',
        username: '',
        password: '',
        repasswd: '',
        role: '2'
            },
            rules: {
        username: [
          { required: true, message: '请输入账号', trigger: 'blur' }
                ],
        password: [
                    { required: true, message: '请输入密码', trigger: 'blur' },
                    { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
                ],
                repasswd: [
                    { validator: validatePass2, trigger: 'blur' }
        ]
            }
        }
    }, 
    methods: {
    submitRegister () {
  this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }

        const user = {
          username: this.form.username.trim(),
          password: this.$common.encrypt(this.form.password.trim()),
          nick: this.form.nick.trim(),
          role: this.form.role
        }

        this.$http.post(this.$constant.baseURL + '/user/register', user).then((res) => {
          if (res.data.code === 200) {
            this.$message({
              message: res.data.message,
              type: 'success'
            })

            this.form = {
              nick: '',
              username: '',
              password: '',
              repasswd: '',
              role: '2'
            }
            this.disfiex = 0
        }
        }).catch((error) => {
        this.$message({
              message: error.message,
            type: 'error'
          })
        })
      })
    },

    submitLogin () {
  this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }

        const user = {
          username: this.form.username.trim(),
          password: this.$common.encrypt(this.form.password.trim())
        }

        this.$http.post(this.$constant.baseURL + '/user/login', user).then((res) => {
          if (res.data.code === 200) {
                this.$message({
              message: '登录成功!',
              type: 'success'
            })
            localStorage.setItem('usertoken', res.data.data)
            this.$router.push('/')
            }
        }).catch((error) => {
        this.$message({
              message: error.message,
            type: 'error'
          })
        })
      })
},

        Signin () {
                this.disfiex = 1
        },

         Signup () {
                this.disfiex = 0
        }
    }
}
</script>

<style scoped>
.login-page {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  padding: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.auth-ambient {
  position: absolute;
  border-radius: 999px;
  filter: blur(30px);
  opacity: 0.7;
}

.auth-ambient-left {
  width: 420px;
  height: 420px;
  left: -80px;
  top: -60px;
  background: radial-gradient(circle, rgba(111, 140, 255, 0.32), transparent 68%);
}

.auth-ambient-right {
  width: 520px;
  height: 520px;
  right: -140px;
  bottom: -140px;
  background: radial-gradient(circle, rgba(62, 207, 142, 0.24), transparent 66%);
}

.auth-shell {
  position: relative;
  z-index: 1;
  width: min(1280px, 100%);
  display: grid;
  grid-template-columns: 1.05fr 0.95fr;
  gap: 28px;
}

.auth-brand,
.auth-panel {
  border: 1px solid rgba(115, 140, 189, 0.18);
  background: rgba(255, 255, 255, 0.76);
  box-shadow: var(--shadow);
  backdrop-filter: blur(20px);
}

.auth-brand {
  border-radius: 32px;
  padding: 48px;
    display: flex;
  flex-direction: column;
  justify-content: space-between;
  background:
    linear-gradient(160deg, rgba(255, 255, 255, 0.92), rgba(242, 247, 255, 0.88)),
    radial-gradient(circle at 20% 20%, rgba(111, 140, 255, 0.14), transparent 30%);
}

.brand-badge {
  display: inline-flex;
  align-self: flex-start;
  padding: 8px 14px;
  border-radius: 999px;
  color: var(--brand-2);
  font-size: 12px;
  letter-spacing: 0.24em;
  background: rgba(111, 140, 255, 0.08);
  border: 1px solid rgba(111, 140, 255, 0.18);
}

.auth-brand h1 {
  margin: 24px 0 16px;
  font-size: 52px;
  line-height: 1.08;
  letter-spacing: -0.03em;
  color: #1b2a4a;
}

.auth-brand p {
  margin: 0;
  max-width: 560px;
  color: var(--muted);
  line-height: 1.9;
  font-size: 16px;
}

.brand-cards {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-top: 36px;
}

.brand-card {
  padding: 22px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255,255,255,0.92), rgba(243,247,255,0.88));
  border: 1px solid rgba(115,140,189,0.14);
}

.card-kicker {
  display: block;
  color: var(--brand);
  font-size: 12px;
  margin-bottom: 12px;
  letter-spacing: 0.2em;
}

.brand-card strong {
  display: block;
  font-size: 20px;
  margin-bottom: 10px;
  color: #1f3152;
}

.brand-card em {
  display: block;
  color: var(--muted);
  font-style: normal;
  line-height: 1.7;
}

.auth-panel {
  border-radius: 32px;
  padding: 30px;
}

.panel-top {
    display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 26px;
}

.panel-kicker {
  color: var(--muted);
  font-size: 12px;
  letter-spacing: 0.22em;
  margin-bottom: 10px;
}

.panel-top h2 {
  margin: 0;
    font-size: 30px;
  color: #223453;
}

.switch-pill {
  display: inline-flex;
  padding: 6px;
  border-radius: 999px;
  background: rgba(111,140,255,0.08);
  border: 1px solid rgba(111,140,255,0.12);
}

.switch-btn {
  min-width: 78px;
  height: 40px;
  border: 0;
  border-radius: 999px;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
}

.switch-btn.active {
  color: white;
  background: linear-gradient(135deg, var(--brand-2), #8ca3ff);
  font-weight: 700;
}

.auth-form {
  margin-top: 12px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 18px;
}

.form-grid.single {
  grid-template-columns: 1fr;
}

.role-group {
  margin-bottom: 18px;
}

.role-title {
  font-size: 14px;
  color: var(--muted);
  margin-bottom: 12px;
}

.role-options {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.role-card {
  position: relative;
  padding: 18px;
  border-radius: 20px;
  border: 1px solid rgba(115,140,189,0.14);
  background: rgba(255,255,255,0.78);
  cursor: pointer;
  transition: all 0.25s ease;
}

.role-card input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.role-card.active {
  border-color: rgba(62,207,142,0.45);
  background: linear-gradient(180deg, rgba(62,207,142,0.12), rgba(111,140,255,0.08));
  box-shadow: 0 16px 40px rgba(112, 142, 191, 0.12);
}

.role-name {
  display: block;
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 8px;
  color: #213454;
}

.role-card small {
  display: block;
  color: var(--muted);
  line-height: 1.6;
}

.auth-actions {
    display: flex;
    align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-top: 18px;
}

.primary-btn {
  min-width: 180px;
  height: 48px;
  border: 0;
  border-radius: 999px;
  color: white;
  font-weight: 800;
  background: linear-gradient(135deg, var(--brand), #6ce5b0) !important;
  box-shadow: 0 16px 44px rgba(62, 207, 142, 0.2);
}

.action-tip {
  color: var(--muted);
}

.action-tip b {
  color: var(--brand-2);
    cursor: pointer;
}

::v-deep .el-form-item__label {
  color: #425676;
  padding-bottom: 8px;
}

::v-deep .el-input__inner {
  height: 48px;
  border-radius: 16px;
  border: 1px solid rgba(115,140,189,0.16);
  background: rgba(255,255,255,0.92);
  color: var(--text);
}

::v-deep .el-input__inner:focus {
  border-color: rgba(62,207,142,0.42);
}

::v-deep .el-form-item__error {
  color: #ff8ea0;
}

@media (max-width: 1100px) {
  .auth-shell {
    grid-template-columns: 1fr;
  }

  .auth-brand h1 {
    font-size: 40px;
  }
}

@media (max-width: 768px) {
  .login-page {
    padding: 20px;
  }

  .auth-brand,
  .auth-panel {
    padding: 24px;
  }

  .brand-cards,
  .role-options,
  .form-grid {
    grid-template-columns: 1fr;
  }

  .panel-top,
  .auth-actions {
    flex-direction: column;
    align-items: stretch;
}
}
</style>
