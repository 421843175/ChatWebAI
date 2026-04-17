<script>
export default {
  data() {
    return {
      layerList: [],
      model: [],
      hasModelData: false,
      data: ['默认', '愤怒', '难过', '生气', '思考', '笑1', '笑2', '笑3', '震惊', '自信'],
      emojo: [
      {
        "src": "/static/img/a默认.45987cd.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/思考.4b31f79.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/愤怒.c77ac3f.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/生气.a506aa6.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/笑1.4b6da48.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/笑2.b9a6048.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/笑3.5943c36.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/自信.89df0f4.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/难过.3c1bc7e.png",
        "width": 1158,
        "height": 1287
      },
      {
        "src": "/static/img/震惊.08193a1.png",
        "width": 1158,
        "height": 1287
      }
      ]
    }
  },
  watch: {
    type: {
      immediate: true,
      handler(newVal) {
        this.handleChange(newVal)
      }
    },
    currentTitle: {
      immediate: true,
      handler(newVal) {
        this.getModel(newVal)
      }
    }
  },
  props: {
    type: {
      type: Number,
      default: 0
    },
    currentTitle: {
      type: String
    }
  },
  computed: {
    frameScale() {
      if (typeof window === 'undefined') {
        return 0.5
      }
      const width = window.innerWidth
      if (width <= 1380) {
        return 0.5
      }
      if (width <= 1680) {
        return 0.5
      }
      return 0.5
    }
  },
  methods: {
    handleChange(value) {
      if (!this.model || !this.model.find || !this.layerList || !this.layerList.forEach) {
        return
      }
      const d = this.model.find(item => item.indexOf(this.data[value]) > -1)
      this.layerList.forEach(item => {
        if (item.category === 'd_model') {
          item.image = d
        }
      })
    },
    getLayerStyle(layer) {
      const style = {
        ...(layer.style || {})
      }
      if (style.rotate !== undefined) {
        delete style.rotate
      }
      return style
    },
    getFrameStyle() {
      return {
        width: `${Math.round(800 * this.frameScale)}px`,
        height: `${Math.round(800 * this.frameScale)}px`
      }
    },
    getCanvasStyle() {
      return {
        transform: `scale(${this.frameScale})`,
        transformOrigin: 'center center'
      }
    },
    getModel(merchant) {
      this.$http.get(this.$constant.baseURL + '/model/getMerchantModel', { merchant }).then(response => {
        if (response.data.code == 200) {
          if (response.data.data == null) {
            this.layerList = []
            this.model = []
            return
              }
              this.layerList = JSON.parse(response.data.data.layers) || []
          this.model = this.emojo.map(item => item.src)
              this.handleChange(this.$props.type)
            }
    })
  }
  },
  mounted() {
    this.getModel(this.currentTitle)
  }
}
</script>

<template>
  <div class="model-shell">
    <div class="model-canvas">
      <div class="model-frame" :style="getFrameStyle()">
        <div class="containers" :style="getCanvasStyle()">
          <div class="target"
          :data-id="layer.id"
          :data-type="layer.category"
            :style="getLayerStyle(layer)"
            :key="layer.id"
            v-for="(layer) in layerList">
            <img :src="layer.image" alt="">
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.model-shell {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.model-canvas {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.model-frame {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  flex-shrink: 0;
}

.containers {
  position: relative;
  width: 800px;
  height: 800px;
  flex-shrink: 0;
}

.target {
  position: absolute;
  left: 0;
  top: 0;
  display: flex;
  justify-content: center;
}

.target img {
  display: block;
}
</style>
