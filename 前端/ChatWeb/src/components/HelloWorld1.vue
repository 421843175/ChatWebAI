<script>
import Moveable from "vue-moveable";
export default {
  components: { Moveable },
  data() {
    const draggable = true;
    const throttleDrag = 1;
    const edgeDraggable = false;
    const startDragRotate = 0;
    const throttleDragRotate = 0;
    const resizable = true;
    const keepRatio = false;
    const snappable = true;
    const bounds = {"left":0,"top":0,"right":0,"bottom":0,"position":"css"};
    const edge = [];
    const targetRef = null;
    const moveableRef = null;
    return {
      draggable,
      throttleDrag,
      edgeDraggable,
      startDragRotate,
      throttleDragRotate,
      resizable,
      keepRatio,
      snappable,
      bounds,
      edge,
      targetRef,
      moveableRef,
      categorizedImages:{},
      extraZs:{},

      nameMap2:{
        后发a_front:'后发',//装饰-前发-衣服-身体-后发
        前发a_front:'前发',//装饰-前发-衣服-身体-后发
        b_decorate:"装饰",//装饰-后发-衣服-身体-前发
        c_clothes:"衣服",//装饰-前发-衣服-身体-后发
        // d_model:"身体",//装饰-后发-衣服-身体-前发
        // e_behind:"后发",//装饰-前发-衣服-身体-后发
      },
      nameMap:{
        a_front:'头发',//装饰-前发-衣服-身体-后发
        b_decorate:"装饰",//装饰-后发-衣服-身体-前发
        c_clothes:"衣服",//装饰-前发-衣服-身体-后发
        // d_model:"身体",//装饰-后发-衣服-身体-前发
        // e_behind:"后发",//装饰-前发-衣服-身体-后发
      },
      layerList: [],
      target:null,
      activeTab: 'a_front', // Set default active tab
      gender: 'Male',
      imageMap:{
        male:[],
        female:[],
      },
      id:'',
      newMap:{},
      tree:{},
      activeTab2:'all',
      activeTab3:'前发',
      currentLayer:{
        resizable:true,
        snappable:true
      }
    };
  },

  computed: {

  },
  methods: {
    changeGender(){
      this.activeTab2='all'
      this.activeTab3='前发'

      this.currentLayer = {}
      this.layerList = []
      this.targetRef = null
      this.loadBody(this.tree);
      this.other(this.tree)
    },
    remove(item) {
      this.layerList = this.layerList.filter(layer => layer.id !== item.id);
    },
    changeTab2(key){
      this.activeTab2 =key
      if(key==='all'){
        this.categorizedImages['b_decorate'] =  [
            this.tree.b_decorate[this.gender].children,
        ]
      }else{
        this.categorizedImages['b_decorate'] =[ this.tree.b_decorate['通用'][key].children]

      }

    },
    changeTab3(key){
      this.activeTab3 =key


    },
    c(){
      this.target = null
      this.targetRef = null
      this.id=null
      this.layerList.forEach((item)=>{
        if (item.category==='后发a_front') {
          item.style.zIndex = item.zIndex;
        }
      })
      this.currentLayer = {
        resizable:true,
        snappable:true
      }
    },
    clear(){
      this.target = null
      this.targetRef = null
      this.id=null
      this.layerList = []
      this.currentLayer = {
        resizable:true,
        snappable:true
      }
      this.loadBody(this.tree);
    },
    async loadImages() {
      // 使用 require.context 动态加载 assets 下的图片
      const context = require.context('@/assets', true, /\.(png|jpe?g|webp)$/);
      
      // 初始化树形结构对象
      const tree = {};

      // 遍历所有图片
      context.keys().forEach((path) => {
        // 获取目录路径
        const parts = path.split('/').slice(2, -1); // 去掉开头的 './' 和结尾的文件名
        let currentLevel = tree;

        // 遍历目录层级
        parts.forEach((part) => {
          if (!currentLevel[part]) {
            currentLevel[part] = {
              name: part,
              children: []
            };
          }
          // 进入下一层级
          currentLevel = currentLevel[part];
        });

        // 添加图片信息到 children 数组
        if( currentLevel.children){
          const img = new Image();
          img.src = context(path);
          img.onload = () => {
            const { width, height } = img;
            currentLevel.children.push({
              src:context(path),
              width, // 可以根据实际图片尺寸调整
              height
            });
          };

        }
      });
      // 将树形结构存储到data中
      setTimeout(()=>{
        this.tree = tree;
        console.log(tree)
        this.loadBody(tree)
        this.other(tree)
      },800)
    },
    other(tree){
      this.categorizedImages={
        a_front:[tree.a_front[this.gender].Hair_Front.children ,tree.a_front[this.gender].Hair_Behind.children]  ,
        // e_behind:tree.a_front[this.gender].Hair_Behind.children,

        b_decorate:[tree.b_decorate[this.gender].children],
        c_clothes:[tree.c_clothes[this.gender].children],
        // d_model:tree.d_model[this.gender].children,
      }
      delete  tree.b_decorate['通用'].name
      delete  tree.b_decorate['通用'].children

      this.extraZs =tree.b_decorate['通用']
      console.log( this.categorizedImages)
    },
    loadBody(tree){
      // console.log(tree.d_model[this.gender].children[0])
      this.addLayer('d_model',tree.d_model[this.gender].children[0])
      this.addLayer('a_front',tree.a_front[this.gender].Hair_Front.children[0],'前发')
      // this.addLayer('a_front',tree.a_front[this.gender].Hair_Behind.children[0],'后发')

      this.addLayer('ny',tree.ny[this.gender].children[0])
    },
    getScaledDimensions(originalWidth, originalHeight, scale) {
      return {
        width: Math.round(originalWidth * scale)+'px',
        height: Math.round(originalHeight * scale)+'px'
      };
    },
    activeLayer(self,layer){
      if (layer.category==='d_model'||layer.category==='ny') {
        return
      }
      // this.layerList.forEach((item)=>{
      //   if (item.category==='e_behind') {
      //     layer.style.zIndex = 10
      //   }
      //   if (item.category==='d_model') {
      //     layer.style.zIndex = 10
      //   }
      // })
      this.targetRef=null
      this.currentLayer = {}

      this.$nextTick(()=>{
        this.currentLayer = layer;
        layer.style.zIndex = 100

        this.layerList.forEach((item)=>{
          if (item.id!==layer.id) {
            item.style.zIndex = item.zIndex;
          }
        })
        this.id = layer.id
        this.targetRef = document.querySelector(`[data-id="${layer.id}"]`)
      })
    },
    addLayer(category,image,category2=''){
      // let layered = this.layerList.find((item)=>item.category===category)

      category = category2+category

        let cur =  this.layerList.find((item)=>item.category===category)
        if(cur && cur.category!=='b_decorate'){
          this.layerList.forEach((item) => {
            if (item.id === cur.id) {
              item.image = image.src
              item.style = {
                ...item.style,
                ...this.getScaledDimensions(image.width, image.height, 0.5),
              }
            }
          })
          return

        }
        // let layered = this.layerList.find((item)=>item.category===category)




      // if(layered&&layered.category!=='b_decorate'){
      //   this.$nextTick(()=>{
      //     this.targetRef = null
      //
      //     //寻找自定义属性
      //     // document.querySelectorAll('.target').forEach((item) => {
      //     //   if(item.getAttribute('data-id') === layered.id){
      //     //     this.activeLayer(item.children[0],layered)
      //     //   }
      //     // })
      //     // this.activeLayer(,layered)
      //   })
      //   return
      //
      // }
      let layer = {
        category:category,
        id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
          var r = Math.random() * 16 | 0,
              v = c == 'x' ? r : (r & 0x3 | 0x8);
          return v.toString(16);
        }),
        image:image.src,
        resizable:true,
        snappable:true,
        zIndex:10,
        style:{
          ...this.getScaledDimensions(image.width,image.height,0.5) ,
          left:0,
          top:0,
          rotate:0,
          zIndex:10,
        },
      }

      if (category==='后发a_front') {
        layer.zIndex = 0
        layer.style.transform= 'translate(254px, 162px)'

      }
      if(this.gender==='Female'){
        if (category==='c_clothes') {
          layer.style.transform= 'translate(170px, 460px)'
        }
        if (category==='前发a_front') {
          layer.style.transform= 'translate(175px, 194px)'
        }
        if (category==='后发a_front') {
          layer.zIndex = 0
          layer.style.transform= 'translate(189px, 184px)'


        }
        if (category==='ny') {
          layer.style.transform= 'translate(171px, 488px)'
        }
      }else{
        if (category==='c_clothes') {
          layer.style.transform= 'translate(172px, 459px)'
        }
        if (category==='ny') {
          layer.style.transform= 'translate(171px, 488px)'
        }
        if (category==='前发a_front') {
          layer.style.transform= 'translate(172px, 172px)'
        }
        if (category==='后发a_front') {
          layer.zIndex = 0
          layer.style.transform= 'translate(169px, 158px)'


        }
      }
      if (category==='b_decorate') {
        layer.zIndex = 10

      }
      if (category==='d_model'){
        layer.style.left = "50%";
        layer.style.top = '50%';
        layer.zIndex = 1
        layer.style.transform = ' translate(-50%, -50%)';
      }
      layer.style.zIndex = layer.zIndex
      console.log(layer)
      this.layerList.push(layer);
    },
    onDrag(e) {
      e.target.style.transform = e.transform;
    },
    onResize(e) {
      e.target.style.width = `${e.width}px`;
      e.target.style.height = `${e.height}px`;
      e.target.style.transform = e.drag.transform;
    },
    onBound(e) {
      console.log(e);
    },
    save(){
      this.layerList.forEach((item)=>{
        if (item.category==='后发a_front') {
          item.style.zIndex = item.zIndex;
        }
      })
      localStorage.setItem('layerList',JSON.stringify(
          {
            layerList:this.layerList,
            gender:this.gender
          }
      ))
      alert('保存成功')
    },
    updateLayerData(e) {
      if (this.targetRef) {
        let target =this.currentLayer
        if (target) {
          target.style = {
            ...target.style,
            ...e.style
          }
          // target.transformObject = e.transformObject
        }
      }
    },
    onRender (e) {
      e.target.style.cssText += e.cssText
      requestAnimationFrame(() => {
        this.updateLayerData(e)

      })
      // layers.value.forEach((item) => {
      // 	if (item.id === e.target.getAttribute('data-id')) {
      // 		item.style = {
      // 			...item.style,
      // 			...e.style
      // 		}
      // 		item.transformObject = e.transformObject
      // 	}
      // })
    }
  },
  mounted() {
    this.targetRef = this.$refs.targetRef;

    this.moveableRef = this.$refs.moveableRef;
    let a = localStorage.getItem('layerList')
    if(a) {
      const original = JSON.parse(a)
      // 示例使用0.5倍缩放，可根据需要调整缩放系数
      this.layerList = original.layerList || []
      this.gender = original.gender
    }
    this.loadImages()
  }
};
</script>
<template>
  <div class="root">
    <div class="view">
      <div 
        class="view_item" 
        v-for="(item,index) in layerList.filter(item=>item.category!=='d_model'&&item.category!=='ny')"
        :key="item.id"
        :class="{ 'active-layer': id === item.id }"
      >
        <div 
          class="layer-item"
          @click="activeLayer({},item)"
        >
          <span class="layer-name">{{nameMap2[item.category]}}</span>
          <span class="layer-index">#{{index+1}}</span>
        </div>
      </div>
    </div>
    <div
        class="container"
        @click="c"
    >
      <div  class="target"
            :data-id="layer.id"
            :data-type="layer.category"
            @click.stop="activeLayer($event,layer)"
            :style="{...layer.style,width:'450px'}" :key="layer.id" v-for="(layer) in layerList">
        <div  v-if="layer.category!=='d_model'&&currentLayer.id===layer.id" @click="remove(layer)" style="position: absolute;text-align: left;margin-top: -40px">X</div>

        <img
             :style="{width:layer.style.width,height:layer.style.height}" :src="layer.image" alt="">
      </div>

      <Moveable
          ref="moveableRef"
          :target="targetRef"
          :draggable="draggable"
          :throttleDrag="throttleDrag"
          :edgeDraggable="edgeDraggable"
          :startDragRotate="startDragRotate"
          :throttleDragRotate="throttleDragRotate"
          :resizable="currentLayer.resizable"
          :keepRatio="keepRatio"
          :snappable="currentLayer.snappable"
          :bounds="bounds"
          :edge="edge"
          @drag="onDrag"
          @render="onRender"

          @resize="onResize"
          @bound="onBound"/>
    </div>

    <div class="sc-box">
      <div class="gender-selector">
        <div>性别：</div>
        <label class="radio-item">
          <input 
            type="radio" 
            value="Male"
            v-model="gender"
            @change="changeGender"

            class="radio-input"
          >
          <span class="radio-label">男</span>
        </label>
        <label class="radio-item">
          <input 
            type="radio" 
            value="Female"
            v-model="gender"
            @change="changeGender"
            class="radio-input"
          >
          <span class="radio-label">女</span>
        </label>
        <div class="btn" @click="save">保存</div>
        <div class="btn" @click="clear">重置</div>
      </div>
      <div class="tabs">
        <div
          v-for="(key) in Object.keys(nameMap)"
          :key="key"
          class="tab"
          :class="{ active: activeTab === key }"
          @click="activeTab = key"
        >
          {{ nameMap[key] }}
        </div>
      </div>
      <div class="tabs"  v-if="activeTab==='a_front'">
        <div
            v-for="(key) in ['前发','后发']"
            :key="key"
            class="tab"
            :class="{ active: activeTab3 === key }"
            @click="changeTab3(key)"
        >
          {{ key }}
        </div>
      </div>
      <div class="tabs" style="flex-wrap:wrap " v-if="activeTab==='b_decorate'">

        <div style="width: 70px;text-align: center" class="tab" @click="changeTab2('all')" :class="{ active: activeTab2 === 'all' }">默认</div>
        <div
            v-for="(key) in Object.keys(extraZs)"
            :key="key"
            class="tab"
            :class="{ active: activeTab2 === key }"
            @click="changeTab2(key)"
            style="width: 70px;text-align: center"
        >
          {{ key }}
        </div>
      </div>

      <div style="height:calc(60vh);overflow-y: auto">
        <div v-for="(images, category) in categorizedImages" :key="category" v-show="activeTab === category">
          <div class="image-grid" v-if="category!=='a_front'">
            <img
                @click="addLayer(category,image,)"
                :style="{...getScaledDimensions(image.width,image.height,category==='b_decorate'?0.4:0.2)}"
                class="sc"
                v-for="(image, index) in images[0]"
                :key="index"
                :src="image.src"
                :alt="`${category}-${index}`"
            >
          </div>
          <div class="image-grid" v-if="category==='a_front'">
            <img
                @click="addLayer(category,image,activeTab3)"
                :style="{...getScaledDimensions(image.width,image.height,category==='b_decorate'?0.4:0.2)}"
                class="sc"
                v-for="(image, index) in images[activeTab3==='前发'?0:1]"
                :key="index"
                :src="image.src"
                :alt="`${category}-${index}`"
            >
          </div>
        </div>
      </div>
    </div>

  </div>
</template>
<style >


.target{
  position: absolute;
  left: 0;
  top: 0;
  cursor: pointer;
  display: flex;justify-content: center;
}
.view{
  width: 200px;
  padding: 10px;
  background: #fafafa;
  border-right: 1px solid #eee;
}
.view_item {
  margin-bottom: 8px;
  transition: all 0.2s ease;
  border-radius: 4px;
  
  &:hover {
    background: #f0f7ff;
    transform: translateX(4px);
    
    .layer-index {
      color: #409eff;
    }
  }
  
  &.active-layer {
    background: #e8f3ff;
    border-left: 3px solid #409eff;
  }
}

.layer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 13px;
  color: #666;
  
  &:hover {
    .layer-name {
      color: #333;
    }
  }
}

.layer-name {
  flex: 1;
  margin-right: 8px;
  transition: color 0.2s;
}

.layer-index {
  font-size: 12px;
  color: #999;
  transition: color 0.2s;
}

.sc-box{
  padding: 20px;
  background: #f5f5f5;
  flex: 1;
}

.sc-box h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 15px 0 10px;
  padding-bottom: 5px;
  border-bottom: 1px solid #ddd;
}
.sc{
  margin-right: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 4px;
  border: 1px solid #eee;
  padding: 6px;
}
.sc:hover {
  border-color: #44aaff;
}

html,
body {
  position: relative;
  height: 100vh;
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html:has(.no-relative) {
  position: relative;
}


.margin .root {
  position: static;
  display: flex;
}



.root {
  position: relative;
  display: flex;
  height: 100vh;
}

.container {
  position: relative;
  width: 800px;
  height: 800px;
  border: 1px solid #ccc;
  margin:  auto 0;

}


.nested .target {
  top: 50px;
  left: 50px
}



.tabs {
  display: flex;
  border-bottom: 1px solid #ddd;
  margin-bottom: 20px;
}

.tab {
  padding: 12px 20px;
  cursor: pointer;
  font-size: 14px;
  color: #666;
  transition: all 0.3s ease;
  border-bottom: 2px solid transparent;
  margin-right: 10px;
}

.tab:hover {
  color: #333;
}

.tab.active {
  color: #409eff;
  border-bottom-color: #409eff;
  font-weight: 500;
}

.image-grid {
  display: flex;
  flex-wrap: wrap;
  gap:20px
}

.gender-selector {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
  padding: 10px 0;
}

.radio-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  margin-right: 15px;
}

.radio-input {
  appearance: none;
  width: 16px;
  height: 16px;
  border: 2px solid #ccc;
  border-radius: 50%;
  margin-right: 8px;
  position: relative;
  transition: all 0.2s ease;
}

.radio-input:checked {
  border-color: #409eff;
}

.radio-input:checked::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: #409eff;
  border-radius: 50%;
}

.radio-label {
  font-size: 14px;
  color: #666;
  transition: color 0.2s ease;
}

.radio-item:hover .radio-label {
  color: #333;
}

.radio-item:hover .radio-input {
  border-color: #999;
}

.btn {
  border: none;
  border-radius: 4px;
  padding: 8px 15px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #409eff;
  color: white;
  position: relative;
  overflow: hidden;
  
  &:hover {
    background: #3080df;
    transform: scale(1.02);
    box-shadow: 0 2px 8px rgba(32, 128, 223, 0.3);
  }
  
  &:active {
    transform: scale(0.98);
    box-shadow: 0 1px 4px rgba(32, 128, 223, 0.2);
  }
  
  &.disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  &.round {
    border-radius: 20px;
  }
  
  &.text {
    background: transparent;
    color: #409eff;
    &:hover {
      background: rgba(64, 158, 255, 0.1);
    }
  }
}
</style>