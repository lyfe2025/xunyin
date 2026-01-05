<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useToast } from '@/components/ui/toast/use-toast'
import ImageUpload from '@/components/common/ImageUpload.vue'
import PhonePreview from '@/components/business/PhonePreview/index.vue'
import { Save, RefreshCw, Plus, Trash2, Smartphone, Copy, ExternalLink } from 'lucide-vue-next'
import {
  getDownloadConfig,
  updateDownloadConfig,
  type UpdateDownloadConfigParams,
} from '@/api/app-config/download'

const { toast } = useToast()

const loading = ref(false)
const submitLoading = ref(false)

// 下载页访问地址
const downloadPageUrl = computed(() => {
  const baseUrl = window.location.origin
  return `${baseUrl}/download`
})

// 复制链接
function copyUrl() {
  navigator.clipboard.writeText(downloadPageUrl.value)
  toast({
    title: '已复制',
    description: '下载页地址已复制到剪贴板',
  })
}

// 寻印主题色默认值
const form = reactive<UpdateDownloadConfigParams>({
  pageTitle: '',
  pageDescription: '',
  favicon: '',
  // 背景配置
  backgroundType: 'gradient',
  backgroundImage: '',
  backgroundColor: '#2C2C2C',
  gradientStart: '#8B4513',
  gradientEnd: '#2C2C2C',
  gradientDirection: '135deg',
  // APP信息
  appIcon: '',
  appName: '',
  appSlogan: '',
  sloganColor: '#F5F5DC',
  // 按钮样式
  buttonStyle: 'filled',
  buttonPrimaryColor: '#C53D43',
  buttonSecondaryColor: 'rgba(255,255,255,0.2)',
  buttonRadius: 'full',
  // 按钮文本
  iosButtonText: '',
  androidButtonText: '',
  featureList: [],
  iosStoreUrl: '',
  androidStoreUrl: '',
  androidApkUrl: '',
  qrcodeImage: '',
  footerText: '',
})

// 计算背景样式
const backgroundStyle = computed(() => {
  if (form.backgroundType === 'image' && form.backgroundImage) {
    return {
      backgroundImage: `url(${form.backgroundImage})`,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    }
  } else if (form.backgroundType === 'color') {
    return { backgroundColor: form.backgroundColor || '#2C2C2C' }
  } else {
    const dir = form.gradientDirection || '135deg'
    const start = form.gradientStart || '#8B4513'
    const end = form.gradientEnd || '#2C2C2C'
    return { backgroundImage: `linear-gradient(${dir}, ${start} 0%, ${end} 100%)` }
  }
})

// 预览数据
const previewData = computed(() => ({
  appIcon: form.appIcon,
  appName: form.appName || '寻印',
  appSlogan: form.appSlogan || '城市文化探索与数字印记收藏',
  sloganColor: form.sloganColor || '#F5F5DC',
  buttonStyle: form.buttonStyle || 'filled',
  buttonPrimaryColor: form.buttonPrimaryColor || '#C53D43',
  buttonSecondaryColor: form.buttonSecondaryColor || 'rgba(255,255,255,0.2)',
  buttonRadius: form.buttonRadius || 'full',
  featureList: form.featureList || [],
}))

// 按钮圆角映射
const buttonRadiusClass = computed(() => {
  const radiusMap: Record<string, string> = {
    none: 'rounded-none',
    sm: 'rounded',
    md: 'rounded-lg',
    lg: 'rounded-xl',
    full: 'rounded-full',
  }
  return radiusMap[previewData.value.buttonRadius || 'full'] || 'rounded-full'
})

// 主按钮样式（根据 buttonStyle 计算）- 下载页主按钮是白底
const primaryButtonStyle = computed(() => {
  const style = previewData.value.buttonStyle || 'filled'
  const color = previewData.value.buttonPrimaryColor || '#C53D43'

  if (style === 'outlined') {
    return {
      backgroundColor: 'transparent',
      border: `2px solid #ffffff`,
      color: '#ffffff',
    }
  } else if (style === 'glass') {
    return {
      backgroundColor: 'rgba(255,255,255,0.15)',
      backdropFilter: 'blur(10px)',
      border: `1px solid rgba(255,255,255,0.3)`,
      color: '#ffffff',
    }
  }
  // filled (default) - 白底彩字
  return {
    backgroundColor: '#ffffff',
    color: color,
  }
})

// 次按钮样式（根据 buttonStyle 计算）
const secondaryButtonStyle = computed(() => {
  const style = previewData.value.buttonStyle || 'filled'
  const color = previewData.value.buttonSecondaryColor || 'rgba(255,255,255,0.2)'

  if (style === 'outlined') {
    return {
      backgroundColor: 'transparent',
      border: `2px solid rgba(255,255,255,0.5)`,
      color: '#ffffff',
    }
  } else if (style === 'glass') {
    return {
      backgroundColor: 'rgba(255,255,255,0.1)',
      backdropFilter: 'blur(10px)',
      border: `1px solid rgba(255,255,255,0.2)`,
      color: '#ffffff',
    }
  }
  // filled (default)
  return {
    backgroundColor: color,
    color: '#ffffff',
  }
})

// 从 rgba 或 hex 颜色中提取 hex 颜色值
function extractHexColor(color: string | undefined): string {
  if (!color) return '#ffffff'
  // 如果已经是 hex 格式
  if (color.startsWith('#')) return color.slice(0, 7)
  // 如果是 rgba 格式，提取 rgb 值转换为 hex
  const rgbaMatch = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/)
  if (rgbaMatch) {
    const r = parseInt(rgbaMatch[1] || '255', 10)
      .toString(16)
      .padStart(2, '0')
    const g = parseInt(rgbaMatch[2] || '255', 10)
      .toString(16)
      .padStart(2, '0')
    const b = parseInt(rgbaMatch[3] || '255', 10)
      .toString(16)
      .padStart(2, '0')
    return `#${r}${g}${b}`
  }
  return '#ffffff'
}

// 更新次要按钮颜色（保留透明度）
function updateSecondaryColor(event: Event) {
  const hex = (event.target as HTMLInputElement).value
  // 从当前值中提取透明度
  const currentColor = form.buttonSecondaryColor || 'rgba(255,255,255,0.2)'
  const alphaMatch = currentColor.match(/,\s*([\d.]+)\)$/)
  const alpha = alphaMatch ? alphaMatch[1] : '0.2'
  // 转换 hex 为 rgba
  const r = parseInt(hex.slice(1, 3), 16)
  const g = parseInt(hex.slice(3, 5), 16)
  const b = parseInt(hex.slice(5, 7), 16)
  form.buttonSecondaryColor = `rgba(${r},${g},${b},${alpha})`
}

// 获取配置
async function getData() {
  loading.value = true
  try {
    const res = await getDownloadConfig()
    Object.assign(form, {
      pageTitle: res.data.pageTitle || '',
      pageDescription: res.data.pageDescription || '',
      favicon: res.data.favicon || '',
      // 背景配置
      backgroundType: res.data.backgroundType || 'gradient',
      backgroundImage: res.data.backgroundImage || '',
      backgroundColor: res.data.backgroundColor || '#2C2C2C',
      gradientStart: res.data.gradientStart || '#8B4513',
      gradientEnd: res.data.gradientEnd || '#2C2C2C',
      gradientDirection: res.data.gradientDirection || '135deg',
      // APP信息
      appIcon: res.data.appIcon || '',
      appName: res.data.appName || '',
      appSlogan: res.data.appSlogan || '',
      sloganColor: res.data.sloganColor || '#F5F5DC',
      // 按钮样式
      buttonStyle: res.data.buttonStyle || 'filled',
      buttonPrimaryColor: res.data.buttonPrimaryColor || '#C53D43',
      buttonSecondaryColor: res.data.buttonSecondaryColor || 'rgba(255,255,255,0.2)',
      buttonRadius: res.data.buttonRadius || 'full',
      // 按钮文本
      iosButtonText: res.data.iosButtonText || '',
      androidButtonText: res.data.androidButtonText || '',
      featureList: res.data.featureList || [],
      iosStoreUrl: res.data.iosStoreUrl || '',
      androidStoreUrl: res.data.androidStoreUrl || '',
      androidApkUrl: res.data.androidApkUrl || '',
      qrcodeImage: res.data.qrcodeImage || '',
      footerText: res.data.footerText || '',
    })
  } finally {
    loading.value = false
  }
}

// 保存
async function handleSubmit() {
  submitLoading.value = true
  try {
    await updateDownloadConfig(form)
    toast({ title: '保存成功' })
  } finally {
    submitLoading.value = false
  }
}

// 重置
function handleReset() {
  getData()
  toast({ title: '已重置' })
}

// 添加功能特点
function addFeature() {
  if (!form.featureList) form.featureList = []
  form.featureList.push({ icon: '', title: '', desc: '' })
}

// 删除功能特点
function removeFeature(index: number) {
  form.featureList?.splice(index, 1)
}

onMounted(() => {
  getData()
})
</script>

<template>
  <div class="p-4 sm:p-6">
    <!-- 页面标题 -->
    <div class="flex items-center justify-between mb-4">
      <div>
        <h2 class="text-xl font-bold">下载页配置</h2>
        <p class="text-sm text-muted-foreground">配置 APP 下载落地页的内容和链接</p>
        <div class="flex items-center gap-2 mt-2">
          <span class="text-xs text-muted-foreground">访问地址：</span>
          <code class="text-xs bg-muted px-2 py-1 rounded">{{ downloadPageUrl }}</code>
          <Button variant="ghost" size="sm" class="h-6 px-2" @click="copyUrl">
            <Copy class="h-3 w-3" />
          </Button>
          <a :href="downloadPageUrl" target="_blank">
            <Button variant="ghost" size="sm" class="h-6 px-2">
              <ExternalLink class="h-3 w-3" />
            </Button>
          </a>
        </div>
      </div>
      <div class="flex gap-2">
        <Button variant="outline" size="sm" @click="handleReset" :disabled="loading">
          <RefreshCw class="h-4 w-4 mr-1" />重置
        </Button>
        <Button size="sm" @click="handleSubmit" :disabled="submitLoading">
          <Save class="h-4 w-4 mr-1" />{{ submitLoading ? '保存中...' : '保存' }}
        </Button>
      </div>
    </div>

    <!-- 主内容 -->
    <div class="flex gap-8 h-[calc(100vh-140px)]">
      <!-- 左侧：手机预览 -->
      <div class="shrink-0">
        <PhonePreview :scale="0.62" :show-device-switch="true">
          <template #default>
            <div class="w-full h-full flex flex-col" :style="backgroundStyle">
              <!-- App 信息 -->
              <div class="flex flex-col items-center pt-12 pb-6 px-5">
                <img
                  v-if="previewData.appIcon"
                  :src="previewData.appIcon"
                  class="w-16 h-16 rounded-2xl mb-3 shadow-lg"
                  alt="App Icon"
                />
                <div
                  v-else
                  class="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur mb-3 flex items-center justify-center text-white text-lg font-bold shadow-lg"
                >
                  寻印
                </div>
                <h1 class="text-white text-base font-bold">{{ previewData.appName }}</h1>
                <p class="text-xs mt-1 text-center" :style="{ color: previewData.sloganColor }">
                  {{ previewData.appSlogan }}
                </p>
              </div>

              <!-- 功能特点 -->
              <div v-if="previewData.featureList.length > 0" class="px-4 space-y-2 flex-1">
                <div
                  v-for="(feature, index) in previewData.featureList.slice(0, 3)"
                  :key="index"
                  class="flex items-center gap-3 bg-white/10 backdrop-blur rounded-xl p-3"
                >
                  <div
                    class="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-white text-xs font-medium"
                  >
                    {{ index + 1 }}
                  </div>
                  <p class="text-white text-xs font-medium flex-1 truncate">{{ feature.title }}</p>
                </div>
              </div>
              <div v-else class="flex-1" />

              <!-- 下载按钮 -->
              <div class="px-5 pb-10 space-y-3">
                <button
                  :class="[
                    'w-full h-12 text-sm font-semibold flex items-center justify-center gap-2 shadow-lg transition-all',
                    buttonRadiusClass,
                  ]"
                  :style="primaryButtonStyle"
                >
                  <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                    <path
                      d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
                    />
                  </svg>
                  {{ form.iosButtonText || 'App Store 下载' }}
                </button>
                <button
                  :class="[
                    'w-full h-12 text-sm font-medium flex items-center justify-center gap-2 transition-all',
                    buttonRadiusClass,
                  ]"
                  :style="secondaryButtonStyle"
                >
                  <Smartphone class="h-4 w-4" />
                  {{ form.androidButtonText || 'Android 下载' }}
                </button>
              </div>
            </div>
          </template>
        </PhonePreview>
      </div>

      <!-- 右侧：配置表单 -->
      <div class="flex-1 min-w-0 overflow-y-auto pr-2 space-y-4">
        <!-- 背景设置 -->
        <Card>
          <CardHeader class="py-3">
            <CardTitle class="text-sm">背景设置</CardTitle>
            <CardDescription class="text-xs">配置下载页的背景样式</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="space-y-2">
              <Label class="text-xs">背景类型</Label>
              <Select v-model="form.backgroundType">
                <SelectTrigger>
                  <SelectValue placeholder="选择背景类型" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="gradient">渐变色</SelectItem>
                  <SelectItem value="color">纯色</SelectItem>
                  <SelectItem value="image">图片</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <!-- 渐变色配置 -->
            <template v-if="form.backgroundType === 'gradient'">
              <div class="grid grid-cols-3 gap-4">
                <div class="space-y-1">
                  <Label class="text-xs">起始色</Label>
                  <div class="flex gap-2">
                    <input
                      type="color"
                      v-model="form.gradientStart"
                      class="w-8 h-8 rounded border cursor-pointer"
                    />
                    <Input v-model="form.gradientStart" class="flex-1 text-xs" />
                  </div>
                </div>
                <div class="space-y-1">
                  <Label class="text-xs">结束色</Label>
                  <div class="flex gap-2">
                    <input
                      type="color"
                      v-model="form.gradientEnd"
                      class="w-8 h-8 rounded border cursor-pointer"
                    />
                    <Input v-model="form.gradientEnd" class="flex-1 text-xs" />
                  </div>
                </div>
                <div class="space-y-1">
                  <Label class="text-xs">渐变方向</Label>
                  <Select v-model="form.gradientDirection">
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="to bottom">从上到下</SelectItem>
                      <SelectItem value="to top">从下到上</SelectItem>
                      <SelectItem value="to right">从左到右</SelectItem>
                      <SelectItem value="to left">从右到左</SelectItem>
                      <SelectItem value="135deg">左上到右下</SelectItem>
                      <SelectItem value="45deg">左下到右上</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </template>

            <!-- 纯色配置 -->
            <template v-if="form.backgroundType === 'color'">
              <div class="space-y-1">
                <Label class="text-xs">背景颜色</Label>
                <div class="flex gap-2">
                  <input
                    type="color"
                    v-model="form.backgroundColor"
                    class="w-8 h-8 rounded border cursor-pointer"
                  />
                  <Input v-model="form.backgroundColor" class="flex-1" />
                </div>
              </div>
            </template>

            <!-- 图片配置 -->
            <template v-if="form.backgroundType === 'image'">
              <div class="space-y-1">
                <Label class="text-xs">背景图</Label>
                <ImageUpload v-model="form.backgroundImage" />
              </div>
            </template>
          </CardContent>
        </Card>

        <!-- 基本信息 -->
        <Card>
          <CardHeader class="py-3">
            <CardTitle class="text-sm">APP 信息</CardTitle>
          </CardHeader>
          <CardContent class="space-y-3">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">APP 图标</Label>
                <ImageUpload v-model="form.appIcon" />
              </div>
              <div class="space-y-3">
                <div class="space-y-1">
                  <Label class="text-xs">页面 Favicon</Label>
                  <ImageUpload v-model="form.favicon" />
                </div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">APP 名称</Label>
                <Input v-model="form.appName" placeholder="寻印" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">页面标题</Label>
                <Input v-model="form.pageTitle" placeholder="下载寻印 APP" />
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">APP 标语</Label>
                <Input v-model="form.appSlogan" placeholder="城市文化探索与数字印记收藏" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">标语颜色</Label>
                <div class="flex gap-2">
                  <input
                    type="color"
                    v-model="form.sloganColor"
                    class="w-8 h-8 rounded border cursor-pointer"
                  />
                  <Input v-model="form.sloganColor" class="flex-1" />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <!-- 按钮样式 -->
        <Card>
          <CardHeader class="py-3">
            <CardTitle class="text-sm">按钮样式</CardTitle>
            <CardDescription class="text-xs">配置下载按钮的样式</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">按钮风格</Label>
                <Select v-model="form.buttonStyle">
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="filled">填充</SelectItem>
                    <SelectItem value="outlined">描边</SelectItem>
                    <SelectItem value="glass">毛玻璃</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-1">
                <Label class="text-xs">按钮圆角</Label>
                <Select v-model="form.buttonRadius">
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">无圆角</SelectItem>
                    <SelectItem value="sm">小圆角</SelectItem>
                    <SelectItem value="md">中圆角</SelectItem>
                    <SelectItem value="lg">大圆角</SelectItem>
                    <SelectItem value="full">全圆角</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">主按钮颜色</Label>
                <div class="flex gap-2">
                  <input
                    type="color"
                    v-model="form.buttonPrimaryColor"
                    class="w-8 h-8 rounded border cursor-pointer"
                  />
                  <Input v-model="form.buttonPrimaryColor" class="flex-1" />
                </div>
              </div>
              <div class="space-y-1">
                <Label class="text-xs">次要按钮颜色</Label>
                <div class="flex gap-2">
                  <input
                    type="color"
                    :value="extractHexColor(form.buttonSecondaryColor)"
                    @input="updateSecondaryColor($event)"
                    class="w-8 h-8 rounded border cursor-pointer"
                  />
                  <Input
                    v-model="form.buttonSecondaryColor"
                    class="flex-1"
                    placeholder="rgba(255,255,255,0.2)"
                  />
                </div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">iOS 按钮文本</Label>
                <Input v-model="form.iosButtonText" placeholder="App Store 下载" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">Android 按钮文本</Label>
                <Input v-model="form.androidButtonText" placeholder="Android 下载" />
              </div>
            </div>
          </CardContent>
        </Card>

        <!-- 功能特点 -->
        <Card>
          <CardHeader class="py-3 flex flex-row items-center justify-between">
            <CardTitle class="text-sm">功能特点</CardTitle>
            <Button variant="outline" size="sm" @click="addFeature">
              <Plus class="h-3 w-3 mr-1" />添加
            </Button>
          </CardHeader>
          <CardContent class="space-y-2">
            <div
              v-for="(feature, index) in form.featureList"
              :key="index"
              class="flex gap-2 items-center"
            >
              <Input v-model="feature.title" placeholder="功能标题" class="flex-1" />
              <Button variant="ghost" size="icon" class="shrink-0" @click="removeFeature(index)">
                <Trash2 class="h-4 w-4 text-destructive" />
              </Button>
            </div>
            <p
              v-if="!form.featureList?.length"
              class="text-xs text-muted-foreground text-center py-2"
            >
              暂无功能特点
            </p>
          </CardContent>
        </Card>

        <!-- 下载链接 -->
        <Card>
          <CardHeader class="py-3">
            <CardTitle class="text-sm">下载链接</CardTitle>
            <CardDescription class="text-xs">
              Android 下载优先级：APK 直接下载 &gt; 版本管理最新 APK &gt; 应用商店
            </CardDescription>
          </CardHeader>
          <CardContent class="space-y-3">
            <div class="space-y-1">
              <Label class="text-xs">iOS App Store</Label>
              <Input v-model="form.iosStoreUrl" placeholder="https://apps.apple.com/..." />
            </div>
            <div class="space-y-1">
              <Label class="text-xs">Android 应用商店</Label>
              <Input v-model="form.androidStoreUrl" placeholder="https://play.google.com/..." />
              <p class="text-xs text-muted-foreground">当 APK 链接为空时使用</p>
            </div>
            <div class="space-y-1">
              <div class="flex items-center justify-between">
                <Label class="text-xs">APK 直接下载</Label>
                <span class="text-xs text-muted-foreground">
                  推荐使用
                  <RouterLink to="/app-config/version" class="text-primary hover:underline">
                    版本管理
                  </RouterLink>
                  上传 APK
                </span>
              </div>
              <Input
                v-model="form.androidApkUrl"
                placeholder="留空则自动使用版本管理中的最新 APK"
              />
              <p class="text-xs text-muted-foreground">手动填写将覆盖版本管理的链接，建议留空</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 下载页无需额外样式，状态栏已由 PhonePreview 组件处理 */
</style>
