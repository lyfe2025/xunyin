<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
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
import { Save, RefreshCw, Palette, ToggleLeft, Settings2 } from 'lucide-vue-next'
import {
  getLoginConfig,
  updateLoginConfig,
  type UpdateLoginConfigParams,
} from '@/api/app-config/login'
import { listAgreements, type Agreement } from '@/api/app-config/agreement'
import { listConfig, updateConfig, addConfig, type SysConfig } from '@/api/system/config'

const { toast } = useToast()

const loading = ref(false)
const submitLoading = ref(false)
const activeTab = ref('appearance')

// 登录页配置表单 - 寻印主题色
const form = reactive<UpdateLoginConfigParams>({
  // 背景配置
  backgroundType: 'gradient',
  backgroundImage: '',
  backgroundColor: '#2C2C2C',
  gradientStart: '#8B4513', // 赭石色
  gradientEnd: '#2C2C2C', // 墨色
  gradientDirection: '135deg',
  // Logo配置
  logoImage: '',
  logoSize: 'normal',
  // 标语配置
  slogan: '',
  sloganColor: '#F5F5DC', // 米白色
  // 按钮样式
  buttonStyle: 'filled',
  buttonPrimaryColor: '#C53D43', // 朱砂红
  buttonSecondaryColor: 'rgba(255,255,255,0.2)',
  buttonRadius: 'full',
  // 按钮文本
  wechatButtonText: '',
  phoneButtonText: '',
  emailButtonText: '',
  guestButtonText: '',
  // 登录方式
  wechatLoginEnabled: true,
  appleLoginEnabled: true,
  googleLoginEnabled: false,
  phoneLoginEnabled: true,
  emailLoginEnabled: false,
  guestModeEnabled: false,
  // 协议配置
  agreementSource: 'builtin',
  userAgreementUrl: '',
  privacyPolicyUrl: '',
})

// 三方登录配置表单（从 SysConfig 读取）
const oauthForm = reactive({
  'oauth.wechat.appId': '',
  'oauth.wechat.appSecret': '',
  'oauth.google.clientId': '',
  'oauth.google.clientSecret': '',
  'oauth.apple.teamId': '',
  'oauth.apple.clientId': '',
  'oauth.apple.keyId': '',
  'oauth.apple.privateKey': '',
})

const configMap = ref<Record<string, SysConfig>>({})

// 协议数据
const agreements = ref<Agreement[]>([])
const userAgreement = computed(() => agreements.value.find((a) => a.type === 'user_agreement'))
const privacyPolicy = computed(() => agreements.value.find((a) => a.type === 'privacy_policy'))

// 预览数据
const previewData = computed(() => ({
  backgroundType: form.backgroundType,
  backgroundImage: form.backgroundImage,
  backgroundColor: form.backgroundColor,
  gradientStart: form.gradientStart,
  gradientEnd: form.gradientEnd,
  gradientDirection: form.gradientDirection,
  logoImage: form.logoImage,
  logoSize: form.logoSize,
  slogan: form.slogan,
  sloganColor: form.sloganColor,
  buttonStyle: form.buttonStyle,
  buttonPrimaryColor: form.buttonPrimaryColor,
  buttonSecondaryColor: form.buttonSecondaryColor,
  buttonRadius: form.buttonRadius,
  wechatLoginEnabled: form.wechatLoginEnabled,
  appleLoginEnabled: form.appleLoginEnabled,
  googleLoginEnabled: form.googleLoginEnabled,
  phoneLoginEnabled: form.phoneLoginEnabled,
  emailLoginEnabled: form.emailLoginEnabled,
  guestModeEnabled: form.guestModeEnabled,
}))

// 计算是否有第三方登录图标（Apple/Google）
const hasThirdPartyIcons = computed(() => {
  return previewData.value.appleLoginEnabled || previewData.value.googleLoginEnabled
})

// 计算背景样式
const backgroundStyle = computed(() => {
  const data = previewData.value
  if (data.backgroundType === 'image' && data.backgroundImage) {
    return {
      backgroundImage: `url(${data.backgroundImage})`,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    }
  } else if (data.backgroundType === 'color') {
    return { backgroundColor: data.backgroundColor || '#1a1a2e' }
  } else {
    // gradient
    const dir = data.gradientDirection || 'to bottom'
    const start = data.gradientStart || '#667eea'
    const end = data.gradientEnd || '#764ba2'
    return { backgroundImage: `linear-gradient(${dir}, ${start} 0%, ${end} 100%)` }
  }
})

// Logo 尺寸映射
const logoSizeClass = computed(() => {
  const sizeMap: Record<string, string> = {
    small: 'w-16 h-16',
    normal: 'w-20 h-20',
    large: 'w-24 h-24',
  }
  return sizeMap[previewData.value.logoSize || 'normal'] || 'w-20 h-20'
})

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

// 主按钮样式（根据 buttonStyle 计算）
const primaryButtonStyle = computed(() => {
  const style = previewData.value.buttonStyle || 'filled'
  const color = previewData.value.buttonPrimaryColor || '#C53D43'

  if (style === 'outlined') {
    return {
      backgroundColor: 'transparent',
      border: `2px solid ${color}`,
      color: color,
    }
  } else if (style === 'glass') {
    return {
      backgroundColor: 'rgba(255,255,255,0.15)',
      backdropFilter: 'blur(10px)',
      border: `1px solid rgba(255,255,255,0.3)`,
      color: '#ffffff',
    }
  }
  // filled (default)
  return {
    backgroundColor: color,
    color: '#ffffff',
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

// 获取登录页配置
async function getLoginData() {
  try {
    const res = (await getLoginConfig()) as any
    const data = res.data || res
    Object.assign(form, {
      // 背景配置
      backgroundType: data.backgroundType || 'gradient',
      backgroundImage: data.backgroundImage || '',
      backgroundColor: data.backgroundColor || '#2C2C2C',
      gradientStart: data.gradientStart || '#8B4513',
      gradientEnd: data.gradientEnd || '#2C2C2C',
      gradientDirection: data.gradientDirection || '135deg',
      // Logo配置
      logoImage: data.logoImage || '',
      logoSize: data.logoSize || 'normal',
      // 标语配置
      slogan: data.slogan || '',
      sloganColor: data.sloganColor || '#F5F5DC',
      // 按钮样式
      buttonStyle: data.buttonStyle || 'filled',
      buttonPrimaryColor: data.buttonPrimaryColor || '#C53D43',
      buttonSecondaryColor: data.buttonSecondaryColor || 'rgba(255,255,255,0.2)',
      buttonRadius: data.buttonRadius || 'full',
      // 按钮文本
      wechatButtonText: data.wechatButtonText || '',
      phoneButtonText: data.phoneButtonText || '',
      emailButtonText: data.emailButtonText || '',
      guestButtonText: data.guestButtonText || '',
      // 登录方式
      wechatLoginEnabled: data.wechatLoginEnabled,
      appleLoginEnabled: data.appleLoginEnabled,
      googleLoginEnabled: data.googleLoginEnabled,
      phoneLoginEnabled: data.phoneLoginEnabled,
      emailLoginEnabled: data.emailLoginEnabled,
      guestModeEnabled: data.guestModeEnabled,
      // 协议配置
      agreementSource: data.agreementSource || 'builtin',
      userAgreementUrl: data.userAgreementUrl || '',
      privacyPolicyUrl: data.privacyPolicyUrl || '',
    })
  } catch (e) {
    console.error('获取登录页配置失败', e)
  }
}

// 获取协议数据
async function getAgreementData() {
  try {
    const res = (await listAgreements()) as any
    agreements.value = res.data || res || []
  } catch (e) {
    console.error('获取协议数据失败', e)
  }
}

// 获取三方登录配置
async function getOauthData() {
  try {
    const res = await listConfig({ configKey: 'oauth.', pageSize: 50 })
    const configs = res.rows ?? []
    configs.forEach((item: SysConfig) => {
      const value = String(item.configValue ?? '')
      configMap.value[item.configKey] = { ...item, configValue: value }
      if (item.configKey in oauthForm) {
        ;(oauthForm as any)[item.configKey] = value
      }
    })
  } catch (e) {
    console.error('获取三方登录配置失败', e)
  }
}

// 获取所有数据
async function getData() {
  loading.value = true
  try {
    await Promise.all([getLoginData(), getOauthData(), getAgreementData()])
  } finally {
    loading.value = false
  }
}

// 保存登录页配置
async function saveLoginConfig() {
  await updateLoginConfig(form)
}

// 保存三方登录配置
async function saveOauthConfig() {
  const updates: Promise<any>[] = []
  const configNames: Record<string, string> = {
    'oauth.wechat.appId': '微信AppID',
    'oauth.wechat.appSecret': '微信AppSecret',
    'oauth.google.clientId': 'Google Client ID',
    'oauth.google.clientSecret': 'Google Client Secret',
    'oauth.apple.teamId': 'Apple Team ID',
    'oauth.apple.clientId': 'Apple Client ID',
    'oauth.apple.keyId': 'Apple Key ID',
    'oauth.apple.privateKey': 'Apple Private Key',
  }

  for (const [key, value] of Object.entries(oauthForm)) {
    const originalConfig = configMap.value[key]
    if (originalConfig) {
      const originalValue = String(originalConfig.configValue ?? '')
      if (originalValue !== value) {
        updates.push(updateConfig({ ...originalConfig, configValue: value }))
      }
    } else if (value) {
      updates.push(
        addConfig({
          configName: configNames[key] || key,
          configKey: key,
          configValue: value,
          configType: 'Y',
        })
      )
    }
  }

  if (updates.length > 0) {
    await Promise.all(updates)
  }
}

// 保存
async function handleSubmit() {
  submitLoading.value = true
  try {
    await Promise.all([saveLoginConfig(), saveOauthConfig()])
    toast({ title: '保存成功' })
    await getData()
  } catch {
    toast({ title: '保存失败', variant: 'destructive' })
  } finally {
    submitLoading.value = false
  }
}

// 重置
function handleReset() {
  getData()
  toast({ title: '已重置' })
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
        <h2 class="text-xl font-bold">登录页配置</h2>
        <p class="text-sm text-muted-foreground">配置 APP 登录页的外观、登录方式和三方登录</p>
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
              <!-- Logo 和标语 -->
              <div class="flex-1 flex flex-col items-center justify-center px-5">
                <img
                  v-if="previewData.logoImage"
                  :src="previewData.logoImage"
                  :class="[logoSizeClass, 'rounded-2xl mb-4 shadow-lg object-cover']"
                  alt="Logo"
                />
                <div
                  v-else
                  :class="[
                    logoSizeClass,
                    'rounded-2xl bg-white/20 backdrop-blur mb-4 flex items-center justify-center text-white text-xl font-bold shadow-lg',
                  ]"
                >
                  寻印
                </div>
                <p
                  class="text-sm text-center font-medium"
                  :style="{ color: previewData.sloganColor || '#ffffff' }"
                >
                  {{ previewData.slogan || '城市文化探索与数字印记收藏' }}
                </p>
              </div>

              <!-- 登录按钮 -->
              <div class="px-5 pb-4 space-y-3">
                <!-- 主要登录按钮：微信 -->
                <button
                  v-if="previewData.wechatLoginEnabled"
                  :class="[
                    'w-full h-11 text-sm font-medium flex items-center justify-center gap-2 shadow-lg transition-all',
                    buttonRadiusClass,
                  ]"
                  :style="primaryButtonStyle"
                >
                  <!-- 微信图标 -->
                  <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                    <path
                      d="M9.5 4C5.36 4 2 6.69 2 10c0 1.89 1.08 3.56 2.78 4.66l-.7 2.1 2.45-1.23c.89.26 1.85.47 2.97.47.34 0 .68-.02 1-.05-.19-.57-.3-1.17-.3-1.8 0-2.96 2.82-5.35 6.3-5.35.39 0 .77.03 1.14.08C16.83 5.96 13.53 4 9.5 4zm-2.25 3.5c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm4.5 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM16.5 10c-3.04 0-5.5 1.97-5.5 4.4s2.46 4.4 5.5 4.4c.68 0 1.34-.1 1.96-.28l1.79.9-.5-1.49c1.12-.87 1.75-2.05 1.75-3.53 0-2.43-2.46-4.4-5.5-4.4zm-2 2.75c.41 0 .75.34.75.75s-.34.75-.75.75-.75-.34-.75-.75.34-.75.75-.75zm4 0c.41 0 .75.34.75.75s-.34.75-.75.75-.75-.34-.75-.75.34-.75.75-.75z"
                    />
                  </svg>
                  {{ form.wechatButtonText || '微信登录' }}
                </button>

                <!-- 次要登录按钮：手机号 -->
                <button
                  v-if="previewData.phoneLoginEnabled"
                  :class="[
                    'w-full h-11 text-sm font-medium flex items-center justify-center gap-2 transition-all',
                    buttonRadiusClass,
                  ]"
                  :style="secondaryButtonStyle"
                >
                  <!-- 手机图标 -->
                  <svg
                    class="w-5 h-5"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.5"
                  >
                    <rect x="6" y="2" width="12" height="20" rx="2" />
                    <circle cx="12" cy="18" r="1" fill="currentColor" />
                  </svg>
                  {{ form.phoneButtonText || '手机号登录' }}
                </button>

                <!-- 其他登录方式 -->
                <div v-if="hasThirdPartyIcons" class="flex items-center justify-center pt-2">
                  <div class="flex items-center gap-2 text-white/50 text-xs">
                    <div class="w-8 h-px bg-white/30" />
                    <span>其他方式</span>
                    <div class="w-8 h-px bg-white/30" />
                  </div>
                </div>

                <!-- 第三方登录图标 -->
                <div v-if="hasThirdPartyIcons" class="flex justify-center gap-3">
                  <!-- Apple -->
                  <div
                    v-if="previewData.appleLoginEnabled"
                    class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center cursor-pointer hover:bg-white/30 transition-colors"
                  >
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="currentColor">
                      <path
                        d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
                      />
                    </svg>
                  </div>
                  <!-- Google -->
                  <div
                    v-if="previewData.googleLoginEnabled"
                    class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center cursor-pointer hover:bg-white/30 transition-colors"
                  >
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="currentColor">
                      <path
                        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                      />
                      <path
                        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                      />
                      <path
                        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                      />
                      <path
                        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                      />
                    </svg>
                  </div>
                </div>

                <!-- 次要入口：邮箱登录 / 游客体验 -->
                <div
                  v-if="previewData.emailLoginEnabled || previewData.guestModeEnabled"
                  class="flex items-center justify-center gap-3 pt-1"
                >
                  <span
                    v-if="previewData.emailLoginEnabled"
                    class="text-white/60 text-xs cursor-pointer hover:text-white/80"
                  >
                    {{ form.emailButtonText || '邮箱登录' }}
                  </span>
                  <span
                    v-if="previewData.emailLoginEnabled && previewData.guestModeEnabled"
                    class="text-white/40 text-xs"
                  >
                    |
                  </span>
                  <span
                    v-if="previewData.guestModeEnabled"
                    class="text-white/60 text-xs cursor-pointer hover:text-white/80"
                  >
                    {{ form.guestButtonText || '游客体验' }}
                  </span>
                </div>
              </div>

              <!-- 协议 -->
              <div class="px-5 pb-8 text-center">
                <p class="text-white/50 text-[10px] whitespace-nowrap">
                  登录即表示同意
                  <span class="text-white/70 underline">{{
                    userAgreement?.title || '用户协议'
                  }}</span>
                  和
                  <span class="text-white/70 underline">{{
                    privacyPolicy?.title || '隐私政策'
                  }}</span>
                </p>
              </div>
            </div>
          </template>
        </PhonePreview>
      </div>

      <!-- 右侧：配置表单 -->
      <div class="flex-1 min-w-0 overflow-y-auto pr-2">
        <Tabs v-model="activeTab">
          <TabsList class="mb-4">
            <TabsTrigger value="appearance"> <Palette class="h-4 w-4 mr-1" />外观设置 </TabsTrigger>
            <TabsTrigger value="methods"> <ToggleLeft class="h-4 w-4 mr-1" />登录方式 </TabsTrigger>
            <TabsTrigger value="oauth"> <Settings2 class="h-4 w-4 mr-1" />三方配置 </TabsTrigger>
          </TabsList>

          <!-- 外观设置 -->
          <TabsContent value="appearance" class="space-y-4">
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">背景设置</CardTitle>
                <CardDescription class="text-xs">配置登录页的背景样式</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <!-- 背景类型 -->
                <div class="space-y-2">
                  <Label>背景类型</Label>
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
                    <div class="space-y-2">
                      <Label>起始色</Label>
                      <div class="flex gap-2">
                        <input
                          type="color"
                          v-model="form.gradientStart"
                          class="w-10 h-10 rounded border cursor-pointer"
                        />
                        <Input v-model="form.gradientStart" class="flex-1" />
                      </div>
                    </div>
                    <div class="space-y-2">
                      <Label>结束色</Label>
                      <div class="flex gap-2">
                        <input
                          type="color"
                          v-model="form.gradientEnd"
                          class="w-10 h-10 rounded border cursor-pointer"
                        />
                        <Input v-model="form.gradientEnd" class="flex-1" />
                      </div>
                    </div>
                    <div class="space-y-2">
                      <Label>渐变方向</Label>
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
                  <div class="space-y-2">
                    <Label>背景颜色</Label>
                    <div class="flex gap-2">
                      <input
                        type="color"
                        v-model="form.backgroundColor"
                        class="w-10 h-10 rounded border cursor-pointer"
                      />
                      <Input v-model="form.backgroundColor" class="flex-1" />
                    </div>
                  </div>
                </template>

                <!-- 图片配置 -->
                <template v-if="form.backgroundType === 'image'">
                  <div class="space-y-2">
                    <Label>背景图</Label>
                    <ImageUpload v-model="form.backgroundImage" />
                  </div>
                </template>
              </CardContent>
            </Card>

            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">Logo 与标语</CardTitle>
                <CardDescription class="text-xs">配置登录页的 Logo 和标语</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>Logo</Label>
                    <ImageUpload v-model="form.logoImage" />
                  </div>
                  <div class="space-y-4">
                    <div class="space-y-2">
                      <Label>Logo 尺寸</Label>
                      <Select v-model="form.logoSize">
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="small">小 (64px)</SelectItem>
                          <SelectItem value="normal">正常 (80px)</SelectItem>
                          <SelectItem value="large">大 (96px)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div class="space-y-2">
                      <Label>标语颜色</Label>
                      <div class="flex gap-2">
                        <input
                          type="color"
                          v-model="form.sloganColor"
                          class="w-10 h-10 rounded border cursor-pointer"
                        />
                        <Input v-model="form.sloganColor" class="flex-1" />
                      </div>
                    </div>
                  </div>
                </div>
                <div class="space-y-2">
                  <Label>标语</Label>
                  <Input v-model="form.slogan" placeholder="城市文化探索与数字印记收藏" />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">按钮样式</CardTitle>
                <CardDescription class="text-xs">配置登录按钮的样式</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>按钮风格</Label>
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
                  <div class="space-y-2">
                    <Label>按钮圆角</Label>
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
                  <div class="space-y-2">
                    <Label>主按钮颜色</Label>
                    <div class="flex gap-2">
                      <input
                        type="color"
                        v-model="form.buttonPrimaryColor"
                        class="w-10 h-10 rounded border cursor-pointer"
                      />
                      <Input v-model="form.buttonPrimaryColor" class="flex-1" />
                    </div>
                  </div>
                  <div class="space-y-2">
                    <Label>次要按钮颜色</Label>
                    <div class="flex gap-2">
                      <input
                        type="color"
                        :value="extractHexColor(form.buttonSecondaryColor)"
                        @input="updateSecondaryColor($event)"
                        class="w-10 h-10 rounded border cursor-pointer"
                      />
                      <Input
                        v-model="form.buttonSecondaryColor"
                        class="flex-1"
                        placeholder="rgba(255,255,255,0.2)"
                      />
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <!-- 按钮文本配置 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">按钮文本</CardTitle>
                <CardDescription class="text-xs">自定义各登录按钮的显示文本</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>微信登录</Label>
                    <Input v-model="form.wechatButtonText" placeholder="微信登录" />
                  </div>
                  <div class="space-y-2">
                    <Label>手机号登录</Label>
                    <Input v-model="form.phoneButtonText" placeholder="手机号登录" />
                  </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>邮箱登录</Label>
                    <Input v-model="form.emailButtonText" placeholder="邮箱登录" />
                  </div>
                  <div class="space-y-2">
                    <Label>游客模式</Label>
                    <Input v-model="form.guestButtonText" placeholder="游客体验" />
                  </div>
                </div>
              </CardContent>
            </Card>

            <!-- 协议配置 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">协议配置</CardTitle>
                <CardDescription class="text-xs">配置用户协议和隐私政策的来源</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="space-y-2">
                  <Label>协议来源</Label>
                  <Select v-model="form.agreementSource">
                    <SelectTrigger>
                      <SelectValue placeholder="选择协议来源" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="builtin">内置协议（协议管理）</SelectItem>
                      <SelectItem value="external">外部链接</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <!-- 内置协议说明 -->
                <div v-if="form.agreementSource === 'builtin'" class="rounded-md bg-muted p-3">
                  <p class="text-xs text-muted-foreground">
                    协议内容在
                    <RouterLink
                      to="/app-config/agreement"
                      class="text-primary hover:underline font-medium"
                    >
                      协议管理
                    </RouterLink>
                    中维护，APP 将通过接口获取最新版本。
                  </p>
                  <div class="mt-2 text-xs text-muted-foreground">
                    <p>• 用户协议：{{ userAgreement?.title || '未配置' }}</p>
                    <p>• 隐私政策：{{ privacyPolicy?.title || '未配置' }}</p>
                  </div>
                </div>

                <!-- 外部链接配置 -->
                <template v-if="form.agreementSource === 'external'">
                  <div class="space-y-2">
                    <Label>用户协议链接</Label>
                    <Input
                      v-model="form.userAgreementUrl"
                      placeholder="https://example.com/user-agreement"
                    />
                  </div>
                  <div class="space-y-2">
                    <Label>隐私政策链接</Label>
                    <Input
                      v-model="form.privacyPolicyUrl"
                      placeholder="https://example.com/privacy-policy"
                    />
                  </div>
                </template>
              </CardContent>
            </Card>
          </TabsContent>

          <!-- 登录方式 -->
          <TabsContent value="methods" class="space-y-4">
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">登录方式开关</CardTitle>
                <CardDescription class="text-xs">控制 APP 显示哪些登录方式</CardDescription>
              </CardHeader>
              <CardContent class="space-y-1">
                <div class="flex items-center justify-between py-2 border-b">
                  <div>
                    <p class="text-sm font-medium">微信登录</p>
                    <p class="text-xs text-muted-foreground">使用微信账号快速登录</p>
                  </div>
                  <Switch v-model:checked="form.wechatLoginEnabled" />
                </div>
                <div class="flex items-center justify-between py-2 border-b">
                  <div>
                    <p class="text-sm font-medium">Apple 登录</p>
                    <p class="text-xs text-muted-foreground">使用 Apple ID 登录（iOS 用户）</p>
                  </div>
                  <Switch v-model:checked="form.appleLoginEnabled" />
                </div>
                <div class="flex items-center justify-between py-2 border-b">
                  <div>
                    <p class="text-sm font-medium">Google 登录</p>
                    <p class="text-xs text-muted-foreground">使用 Google 账号登录（海外用户）</p>
                  </div>
                  <Switch v-model:checked="form.googleLoginEnabled" />
                </div>
                <div class="flex items-center justify-between py-2 border-b">
                  <div>
                    <p class="text-sm font-medium">手机号登录</p>
                    <p class="text-xs text-muted-foreground">使用手机号 + 验证码登录</p>
                  </div>
                  <Switch v-model:checked="form.phoneLoginEnabled" />
                </div>
                <div class="flex items-center justify-between py-2 border-b">
                  <div>
                    <p class="text-sm font-medium">邮箱登录</p>
                    <p class="text-xs text-muted-foreground">使用邮箱 + 密码登录</p>
                  </div>
                  <Switch v-model:checked="form.emailLoginEnabled" />
                </div>
                <div class="flex items-center justify-between py-2">
                  <div>
                    <p class="text-sm font-medium">游客模式</p>
                    <p class="text-xs text-muted-foreground">允许用户跳过登录体验 APP</p>
                  </div>
                  <Switch v-model:checked="form.guestModeEnabled" />
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <!-- 三方配置 -->
          <TabsContent value="oauth" class="space-y-4">
            <!-- 微信登录 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">微信登录配置</CardTitle>
                <CardDescription class="text-xs">
                  前往
                  <a
                    href="https://open.weixin.qq.com"
                    target="_blank"
                    class="text-primary hover:underline"
                    >微信开放平台</a
                  >
                  → 管理中心 → 移动应用 → 创建应用，审核通过后获取 AppID 和 AppSecret
                </CardDescription>
              </CardHeader>
              <CardContent class="space-y-3">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>AppID</Label>
                    <Input v-model="oauthForm['oauth.wechat.appId']" placeholder="wx..." />
                  </div>
                  <div class="space-y-2">
                    <Label>AppSecret</Label>
                    <Input
                      v-model="oauthForm['oauth.wechat.appSecret']"
                      type="password"
                      placeholder="••••••••"
                    />
                  </div>
                </div>
              </CardContent>
            </Card>

            <!-- Google 登录 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">Google 登录配置</CardTitle>
                <CardDescription class="text-xs">
                  前往
                  <a
                    href="https://console.cloud.google.com/apis/credentials"
                    target="_blank"
                    class="text-primary hover:underline"
                    >Google Cloud Console</a
                  >
                  → 凭据 → 创建凭据 → OAuth 客户端 ID，应用类型选择「iOS」或「Android」
                </CardDescription>
              </CardHeader>
              <CardContent class="space-y-3">
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>Client ID</Label>
                    <Input
                      v-model="oauthForm['oauth.google.clientId']"
                      placeholder="xxx.apps.googleusercontent.com"
                    />
                  </div>
                  <div class="space-y-2">
                    <Label>Client Secret</Label>
                    <Input
                      v-model="oauthForm['oauth.google.clientSecret']"
                      type="password"
                      placeholder="••••••••"
                    />
                  </div>
                </div>
              </CardContent>
            </Card>

            <!-- Apple 登录 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">Apple 登录配置</CardTitle>
                <CardDescription class="text-xs">
                  前往
                  <a
                    href="https://developer.apple.com/account/resources/identifiers"
                    target="_blank"
                    class="text-primary hover:underline"
                    >Apple Developer</a
                  >
                  → Identifiers 创建 Services ID，然后在 Keys 中创建 Sign in with Apple 密钥
                </CardDescription>
              </CardHeader>
              <CardContent class="space-y-3">
                <div class="grid grid-cols-3 gap-4">
                  <div class="space-y-2">
                    <Label>Team ID</Label>
                    <Input v-model="oauthForm['oauth.apple.teamId']" placeholder="XXXXXXXXXX" />
                  </div>
                  <div class="space-y-2">
                    <Label>Client ID (Service ID)</Label>
                    <Input
                      v-model="oauthForm['oauth.apple.clientId']"
                      placeholder="com.example.app"
                    />
                  </div>
                  <div class="space-y-2">
                    <Label>Key ID</Label>
                    <Input v-model="oauthForm['oauth.apple.keyId']" placeholder="XXXXXXXXXX" />
                  </div>
                </div>
                <div class="space-y-2">
                  <Label>Private Key (.p8 内容)</Label>
                  <Textarea
                    v-model="oauthForm['oauth.apple.privateKey']"
                    placeholder="-----BEGIN PRIVATE KEY-----&#10;...&#10;-----END PRIVATE KEY-----"
                    rows="4"
                    class="font-mono text-xs"
                  />
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 登录页无需额外样式，状态栏已由 PhonePreview 组件处理 */
</style>
