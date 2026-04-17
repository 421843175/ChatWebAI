<template>
  <div>
    <div class="operation-bar">
      <el-button type="primary" icon="el-icon-plus" @click="openCreateDialog">新增商品</el-button>
    </div>

    <el-dialog title="新增商品" :visible.sync="createVisible" width="50%" append-to-body>
      <el-form :model="createForm" label-width="96px">
        <el-form-item label="商品名称" required>
          <el-input v-model="createForm.name"></el-input>
        </el-form-item>

        <el-form-item label="品牌">
          <el-input v-model="createForm.brand" placeholder="请输入品牌"></el-input>
        </el-form-item>

        <el-form-item label="品名">
          <el-input v-model="createForm.productName" placeholder="请输入具体品名"></el-input>
        </el-form-item>

        <el-form-item label="价格方案">
          <div v-for="(item, index) in createForm.productPrices" :key="`create-price-${index}`" class="dynamic-row">
            <el-input v-model="item.name" placeholder="方案名称，如标准款"></el-input>
            <el-input-number v-model="item.price" :min="0" :precision="2" :controls="false"></el-input-number>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(createForm.productPrices, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addPriceRow(createForm.productPrices)">+ 添加价格方案</el-button>
        </el-form-item>

        <el-form-item label="特点">
          <div v-for="(item, index) in createForm.features" :key="`create-feature-${index}`" class="dynamic-row single-line">
            <el-input v-model="createForm.features[index]" placeholder="请输入特点"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(createForm.features, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addStringRow(createForm.features)">+ 添加特点</el-button>
        </el-form-item>

        <el-form-item label="规格参数">
          <div v-for="(item, index) in createForm.specifications" :key="`create-spec-${index}`" class="dynamic-row">
            <el-input v-model="item.key" placeholder="参数名，如材质"></el-input>
            <el-input v-model="item.value" placeholder="参数值"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(createForm.specifications, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addKeyValueRow(createForm.specifications)">+ 添加规格参数</el-button>
        </el-form-item>

        <el-form-item label="使用场景">
          <div v-for="(item, index) in createForm.scenes" :key="`create-scene-${index}`" class="dynamic-row single-line">
            <el-input v-model="createForm.scenes[index]" placeholder="请输入使用场景"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(createForm.scenes, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addStringRow(createForm.scenes)">+ 添加使用场景</el-button>
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="createForm.remark" type="textarea" :rows="4" placeholder="请输入补充说明"></el-input>
        </el-form-item>

        <el-form-item label="价格" required>
          <el-input-number v-model="createForm.price" :min="0" :precision="2"></el-input-number>
        </el-form-item>

        <el-form-item label="商品图片">
          <el-upload class="image-uploader" :action="this.$constant.baseURL + '/upload/goods'" :show-file-list="false" :on-success="handleCreateUpload">
            <img v-if="createForm.src" :src="createForm.src" class="upload-image">
            <i v-else class="el-icon-plus uploader-icon"></i>
            <div slot="tip" class="upload-tip">支持JPG/PNG，不超过2MB</div>
          </el-upload>
        </el-form-item>
      </el-form>

      <span slot="footer">
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" @click="submitCreate" :loading="creating">创建商品</el-button>
      </span>
    </el-dialog>

    <el-row :gutter="20">
      <el-col v-for="(item, index) in goodsList" :key="index" :xs="24" :sm="12" :md="8" :lg="6">
        <el-card class="goods-card">
          <img :src="item.src" class="goods-image" @click="openEdit(item)">
          <div class="goods-info">
            <h3>{{ item.name }}</h3>
            <p class="goods-desc">{{ getShortDescription(item.description) }}</p>
            <p class="price">￥{{ item.price }}</p>

            <div class="actions">
              <el-switch v-model="item.islist" active-text="上架" inactive-text="下架" @change="handleStatusChange(item)"></el-switch>
            </div>
            <div class="actions">
              <el-button type="primary" size="mini" @click="openEdit(item)">编辑</el-button>
              <el-button type="dangprimaryer" size="mini" class="delete-btn" @click="handleDelete(item)">删除</el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-pagination layout="prev, pager, next" :current-page="pagination.page" :page-size="pagination.size" :total="pagination.total" @current-change="handlePageChange"></el-pagination>

    <el-dialog title="商品编辑" :visible.sync="editVisible" width="50%" append-to-body>
      <el-form :model="editForm" label-width="96px">
        <el-form-item label="商品名称">
          <el-input v-model="editForm.name"></el-input>
        </el-form-item>

        <el-form-item label="品牌">
          <el-input v-model="editForm.brand" placeholder="请输入品牌"></el-input>
        </el-form-item>

        <el-form-item label="品名">
          <el-input v-model="editForm.productName" placeholder="请输入具体品名"></el-input>
        </el-form-item>

        <el-form-item label="价格方案">
          <div v-for="(item, index) in editForm.productPrices" :key="`edit-price-${index}`" class="dynamic-row">
            <el-input v-model="item.name" placeholder="方案名称，如标准款"></el-input>
            <el-input-number v-model="item.price" :min="0" :precision="2" :controls="false"></el-input-number>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(editForm.productPrices, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addPriceRow(editForm.productPrices)">+ 添加价格方案</el-button>
        </el-form-item>

        <el-form-item label="特点">
          <div v-for="(item, index) in editForm.features" :key="`edit-feature-${index}`" class="dynamic-row single-line">
            <el-input v-model="editForm.features[index]" placeholder="请输入特点"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(editForm.features, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addStringRow(editForm.features)">+ 添加特点</el-button>
        </el-form-item>

        <el-form-item label="规格参数">
          <div v-for="(item, index) in editForm.specifications" :key="`edit-spec-${index}`" class="dynamic-row">
            <el-input v-model="item.key" placeholder="参数名，如材质"></el-input>
            <el-input v-model="item.value" placeholder="参数值"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(editForm.specifications, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addKeyValueRow(editForm.specifications)">+ 添加规格参数</el-button>
        </el-form-item>

        <el-form-item label="使用场景">
          <div v-for="(item, index) in editForm.scenes" :key="`edit-scene-${index}`" class="dynamic-row single-line">
            <el-input v-model="editForm.scenes[index]" placeholder="请输入使用场景"></el-input>
            <el-button type="text" class="danger-text" @click="removeDynamicRow(editForm.scenes, index)">删除</el-button>
          </div>
          <el-button size="mini" plain @click="addStringRow(editForm.scenes)">+ 添加使用场景</el-button>
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="editForm.remark" type="textarea" :rows="4" placeholder="请输入补充说明"></el-input>
        </el-form-item>

        <el-form-item label="价格">
          <el-input-number v-model="editForm.price" :min="0" :precision="2"></el-input-number>
        </el-form-item>

        <el-form-item label="商品图片">
          <el-upload class="image-uploader" :action="this.$constant.baseURL + '/upload/goods'" :show-file-list="false" :on-success="handleUploadSuccess" :before-upload="beforeImageUpload">
            <img v-if="editForm.src" :src="editForm.src" class="upload-image">
            <i v-else class="el-icon-plus uploader-icon"></i>
            <div slot="tip" class="upload-tip">支持JPG/PNG，不超过2MB</div>
          </el-upload>
        </el-form-item>
      </el-form>

      <span slot="footer">
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="submitEdit" :loading="submitting">保存修改</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  data() {
    return {
      goodsList: [],
      pagination: {
        page: 1,
        size: 8,
        total: 0
      },
      editVisible: false,
      submitting: false,
      editForm: this.createEmptyGoodsForm(),
      createVisible: false,
      creating: false,
      createForm: this.createEmptyGoodsForm()
    }
  },
  created() {
    this.loadGoods()
  },
  methods: {
    createEmptyGoodsForm() {
      return {
        id: null,
        name: '',
        brand: '',
        productName: '',
        productPrices: [{ name: '', price: 0 }],
        features: [''],
        specifications: [{ key: '', value: '' }],
        scenes: [''],
        remark: '',
        price: 0,
        src: ''
      }
    },
    parseDescription(description) {
      if (!description) {
        return this.createEmptyGoodsForm()
      }
      try {
        const parsed = JSON.parse(description)
        return {
          id: null,
          name: '',
          brand: parsed.brand || '',
          productName: parsed.productName || '',
          productPrices: Array.isArray(parsed.productPrices) && parsed.productPrices.length ? parsed.productPrices.map(item => ({ name: item.name || '', price: Number(item.price) || 0 })) : [{ name: '', price: 0 }],
          features: Array.isArray(parsed.features) && parsed.features.length ? [...parsed.features] : [''],
          specifications: parsed.specifications && typeof parsed.specifications === 'object' && !Array.isArray(parsed.specifications)
            ? Object.keys(parsed.specifications).map(key => ({ key, value: parsed.specifications[key] }))
            : [{ key: '', value: '' }],
          scenes: Array.isArray(parsed.scenes) && parsed.scenes.length ? [...parsed.scenes] : [''],
          remark: parsed.remark || '',
          price: 0,
          src: ''
        }
      } catch (error) {
        return this.createEmptyGoodsForm()
      }
    },
    buildDescription(form) {
      const specifications = {}
      form.specifications.forEach(item => {
        if (item.key && item.value !== '') {
          specifications[item.key] = item.value
        }
      })

      return JSON.stringify({
        brand: form.brand,
        productName: form.productName,
        productPrices: form.productPrices.filter(item => item.name || item.price).map(item => ({
          name: item.name,
          price: item.price
        })),
        features: form.features.filter(Boolean),
        specifications,
        scenes: form.scenes.filter(Boolean),
        remark: form.remark
      })
    },
    getShortDescription(description) {
      if (!description) {
        return '暂无商品描述'
      }
      try {
        const parsed = JSON.parse(description)
        const pieces = [parsed.brand, parsed.productName].filter(Boolean)
        if (Array.isArray(parsed.features) && parsed.features.length) {
          pieces.push(parsed.features.slice(0, 2).join(' / '))
        }
        return pieces.join(' · ') || '已配置商品描述'
      } catch (error) {
        return '已配置商品描述'
      }
    },
    addPriceRow(list) {
      list.push({ name: '', price: 0 })
    },
    addStringRow(list) {
      list.push('')
    },
    addKeyValueRow(list) {
      list.push({ key: '', value: '' })
    },
    removeDynamicRow(list, index) {
      if (list.length === 1) {
        if (typeof list[0] === 'string') {
          list.splice(0, 1, '')
        } else if (Object.prototype.hasOwnProperty.call(list[0], 'price')) {
          list.splice(0, 1, { name: '', price: 0 })
        } else {
          list.splice(0, 1, { key: '', value: '' })
        }
        return
      }
      list.splice(index, 1)
    },
    async loadGoods() {
      const res = await this.$http.get(this.$constant.baseURL + '/goods/seller', {
        usertoken: localStorage.getItem('usertoken'),
        page: this.pagination.page,
        size: this.pagination.size
      })

      if (res.data.code === 200) {
        this.goodsList = res.data.data.records.map(item => ({
          ...item,
          description: item.description || '',
          islist: Boolean(item.islist)
        }))
        this.pagination.total = res.data.data.total
      }
    },
    openEdit(item) {
      const descriptionForm = this.parseDescription(item.description)
      this.editForm = {
        ...descriptionForm,
        id: item.id,
        name: item.name,
        price: item.price,
        src: item.src
      }
      this.editVisible = true
    },
    async submitEdit() {
      this.submitting = true
      try {
        const dto = {
          id: this.editForm.id,
          name: this.editForm.name,
          description: this.buildDescription(this.editForm),
          price: this.editForm.price,
          src: this.editForm.src,
          usertoken: localStorage.getItem('usertoken')
        }
        await this.$http.post('/goods/update', dto)
        this.$message.success('修改成功')
        this.editVisible = false
        this.loadGoods()
      } finally {
        this.submitting = false
      }
    },
    handleUploadSuccess(res) {
      if (res.code === 200) {
        this.editForm.src = res.data
        this.$message.success('图片上传成功')
      }
    },
    beforeImageUpload(file) {
      const isImage = ['image/jpeg', 'image/png'].includes(file.type)
      const isLt2M = file.size / 1024 / 1024 < 2

      if (!isImage) {
        this.$message.error('仅支持JPG/PNG格式')
        return false
      }
      if (!isLt2M) {
        this.$message.error('图片大小不能超过2MB')
        return false
      }
      return true
    },
    handlePageChange(page) {
      this.pagination.page = page
      this.loadGoods()
    },
    async handleStatusChange(item) {
      try {
        const actualStatus = item.islist ? 1 : 0
        const json = {
          id: item.id,
          status: actualStatus,
          usertoken: localStorage.getItem('usertoken')
        }

        await this.$http.post(this.$constant.baseURL + '/goods/status', json)
        this.$forceUpdate()
      } catch (error) {
        item.islist = !item.islist
        this.$message.error('状态更新失败')
      }
    },
    openCreateDialog() {
      this.createForm = this.createEmptyGoodsForm()
      this.createVisible = true
    },
    handleCreateUpload(res) {
      if (res.code === 200) {
        this.createForm.src = res.data
        this.$message.success('图片上传成功')
      }
    },
    async submitCreate() {
      this.creating = true
      try {
        const json = {
          name: this.createForm.name,
          description: this.buildDescription(this.createForm),
          price: this.createForm.price,
          src: this.createForm.src,
          usertoken: localStorage.getItem('usertoken')
        }

        const res = await this.$http.post(this.$constant.baseURL + '/goods/create', json)

        if (res.data.code === 200) {
          this.$message.success('商品创建成功')
          this.createVisible = false
          this.loadGoods()
        }
      } finally {
        this.creating = false
      }
    },
    async handleDelete(item) {
      try {
        await this.$confirm('确认删除该商品？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })

        const res = await this.$http.post('/goods/delete', {
          id: item.id,
          usertoken: localStorage.getItem('usertoken')
        })

        if (res.data.code === 200) {
          this.$message.success('删除成功')
          this.loadGoods()
        }
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('删除失败')
        }
      }
    }
  }
}
</script>

<style>
.goods-card {
  margin-bottom: 20px;
  transition: box-shadow 0.3s;
}

.goods-card:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.goods-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  cursor: pointer;
}

.goods-info {
  padding: 15px;
}

.goods-info h3 {
  margin: 0 0 10px;
  font-size: 16px;
  color: #303133;
}

.goods-desc {
  min-height: 40px;
  margin: 0 0 10px;
  font-size: 13px;
  line-height: 1.6;
  color: #7b8190;
}

.price {
  color: #f56c6c;
  font-size: 18px;
  margin: 10px 0;
}

.actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.upload-image {
  width: 200px;
  height: 200px;
  object-fit: contain;
}

.uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 200px;
  height: 200px;
  line-height: 200px;
  text-align: center;
}

.upload-tip {
  color: #909399;
  font-size: 12px;
  margin-top: 10px;
}

.el-switch {
  height: 32px;
  display: inline-flex;
  align-items: center;
}

.el-switch__label {
  white-space: nowrap;
  margin-left: 10px;
  margin-right: 5px;
}

.el-switch__label.is-active {
  margin: 0 5px 0 10px;
}

.actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 15px;
  min-width: 240px;
}

.el-card__body {
  padding: 2px !important;
}

.goods-card {
  margin-bottom: 20px;
  transition: box-shadow 0.3s;
  height: 100%;
}

.card-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.goods-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  flex-shrink: 0;
}

.goods-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 15px;
}

.actions {
  margin-top: auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.switch-wrapper {
  flex: 1;
  min-width: 0;
}

.dynamic-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 160px 56px;
  gap: 12px;
  margin-bottom: 10px;
  align-items: center;
}

.dynamic-row.single-line {
  grid-template-columns: minmax(0, 1fr) 56px;
}

.danger-text {
  color: #d85a63;
}

::v-deep .el-switch__label {
  font-size: 12px;
  white-space: nowrap;
  margin: 0 5px;
}

::v-deep .el-switch__label.is-active {
  margin: 0 5px;
}

@media (max-width: 768px) {
  .goods-info h3 {
    font-size: 14px;
  }

  .price {
    font-size: 16px;
  }

  .dynamic-row,
  .dynamic-row.single-line {
    grid-template-columns: 1fr;
  }

  ::v-deep .el-switch__label {
    display: none;
  }
}

.operation-bar {
  margin-bottom: 20px;
  display: flex;
  justify-content: flex-end;
}

.delete-btn {
  margin-left: 10px;
  border-color: #f56c6c;
}

.delete-btn:hover {
  background: #fef0f0;
}
</style>
