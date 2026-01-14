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

// 登录页配置表单 - 寻印主题色（Aurora 暖色调）
// 参数与 Flutter App 登录页完全对齐
const form = reactive<UpdateLoginConfigParams>({
  // 背景配置 - Aurora warm variant（3色渐变）
  backgroundType: 'gradient',
  backgroundImage: '',
  backgroundColor: '#FDF8F5',
  gradientStart: '#FDF8F5', // Aurora warm 起始色
  gradientMiddle: '#F8F5F0', // Aurora warm 中间色
  gradientEnd: '#F5F0EB', // Aurora warm 结束色
  gradientDirection: 'to bottom',
  // Aurora 底纹配置
  auroraEnabled: true,
  auroraPreset: 'warm',
  // Logo配置 - Flutter: 88x88px, 圆角22px
  logoImage: '',
  logoSize: 'normal',
  logoAnimationEnabled: true,
  // 应用名称配置 - Flutter: fontSize 32, letterSpacing 4
  appName: '寻印',
  appNameColor: '#2D2D2D', // Flutter textPrimary
  // 标语配置 - Flutter: fontSize 14, letterSpacing 1, opacity 0.8
  slogan: '探索城市文化，收集专属印记',
  sloganColor: '#666666', // Flutter textSecondary
  // 按钮样式 - Flutter: accent gradient, 圆角14px
  buttonStyle: 'filled',
  buttonPrimaryColor: '#C41E3A', // Flutter AppColors.accent
  buttonGradientEndColor: '#9A1830', // Flutter AppColors.accentDark
  buttonSecondaryColor: 'rgba(196,30,58,0.08)', // accent with 0.08 opacity
  buttonRadius: 'lg', // Flutter 用 14px 圆角，对应 lg
  // 按钮文本
  wechatButtonText: '',
  phoneButtonText: '',
  emailButtonText: '',
  guestButtonText: '',
  // 登录方式
  wechatLoginEnabled: true,
  appleLoginEnabled: true,
  googleLoginEnabled: true,
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
  gradientMiddle: form.gradientMiddle,
  gradientEnd: form.gradientEnd,
  gradientDirection: form.gradientDirection,
  auroraEnabled: form.auroraEnabled,
  auroraPreset: form.auroraPreset,
  logoImage: form.logoImage,
  logoSize: form.logoSize,
  logoAnimationEnabled: form.logoAnimationEnabled,
  appName: form.appName,
  appNameColor: form.appNameColor,
  slogan: form.slogan,
  sloganColor: form.sloganColor,
  buttonStyle: form.buttonStyle,
  buttonPrimaryColor: form.buttonPrimaryColor,
  buttonGradientEndColor: form.buttonGradientEndColor,
  buttonSecondaryColor: form.buttonSecondaryColor,
  buttonRadius: form.buttonRadius,
  wechatLoginEnabled: form.wechatLoginEnabled,
  appleLoginEnabled: form.appleLoginEnabled,
  googleLoginEnabled: form.googleLoginEnabled,
  phoneLoginEnabled: form.phoneLoginEnabled,
  emailLoginEnabled: form.emailLoginEnabled,
  guestModeEnabled: form.guestModeEnabled,
}))

// Aurora 光晕配置（根据预设返回不同配置）
// 尺寸使用像素值，基于手机预览宽度约 375px 计算
type AuroraCircleConfig = { x: string; y: string; size: string; color: string; opacity: number }
const auroraCircles = computed(() => {
  const preset = form.auroraPreset || 'warm'
  const accent = form.buttonPrimaryColor || '#C41E3A'

  // 颜色定义（与 Flutter AppColors 对应）
  const colors = {
    accent, // 品牌红 #C41E3A
    primary: '#425066', // 黛青
    tertiary: '#7BA08C', // 竹青
    sealGold: '#E6B422', // 金色
  }

  // 不同预设的光晕配置（完全匹配 Flutter AuroraVariant.circles）
  // Flutter radiusFactor 是半径占屏幕宽度的比例，这里转换为直径像素值
  // 预览宽度约 375px，radiusFactor 0.5 = 直径 375px，0.35 = 直径 262px
  const presets: Record<string, AuroraCircleConfig[]> = {
    warm: [
      // Flutter: AuroraCircle(0.85, 0.1, 0.5, AppColors.accent, 0.04)
      { x: '85%', y: '10%', size: '375px', color: colors.accent, opacity: 0.04 },
      // Flutter: AuroraCircle(0.15, 0.85, 0.45, AppColors.tertiary, 0.05)
      { x: '15%', y: '85%', size: '337px', color: colors.tertiary, opacity: 0.05 },
      // Flutter: AuroraCircle(0.5, 0.4, 0.35, AppColors.sealGold, 0.02)
      { x: '50%', y: '40%', size: '262px', color: colors.sealGold, opacity: 0.02 },
    ],
    standard: [
      // Flutter: AuroraCircle(0.2, 0.1, 0.35, AppColors.primary, 0.08)
      { x: '20%', y: '10%', size: '262px', color: colors.primary, opacity: 0.08 },
      // Flutter: AuroraCircle(0.85, 0.35, 0.3, AppColors.accent, 0.06)
      { x: '85%', y: '35%', size: '225px', color: colors.accent, opacity: 0.06 },
      // Flutter: AuroraCircle(0.4, 0.85, 0.4, AppColors.tertiary, 0.05)
      { x: '40%', y: '85%', size: '300px', color: colors.tertiary, opacity: 0.05 },
    ],
    golden: [
      // Flutter: AuroraCircle(0.5, 0.12, 0.4, AppColors.sealGold, 0.08)
      { x: '50%', y: '12%', size: '300px', color: colors.sealGold, opacity: 0.08 },
      // Flutter: AuroraCircle(0.1, 0.5, 0.35, AppColors.primary, 0.06)
      { x: '10%', y: '50%', size: '262px', color: colors.primary, opacity: 0.06 },
      // Flutter: AuroraCircle(0.85, 0.75, 0.3, AppColors.accent, 0.05)
      { x: '85%', y: '75%', size: '225px', color: colors.accent, opacity: 0.05 },
    ],
    celebration: [
      // Flutter: AuroraCircle(0.5, 0.15, 0.5, AppColors.sealGold, 0.12)
      { x: '50%', y: '15%', size: '375px', color: colors.sealGold, opacity: 0.12 },
      // Flutter: AuroraCircle(0.1, 0.5, 0.35, AppColors.primary, 0.06)
      { x: '10%', y: '50%', size: '262px', color: colors.primary, opacity: 0.06 },
      // Flutter: AuroraCircle(0.9, 0.7, 0.3, AppColors.accent, 0.05)
      { x: '90%', y: '70%', size: '225px', color: colors.accent, opacity: 0.05 },
    ],
  }

  return presets[preset] || presets.warm
})

// 登录按钮样式（根据 buttonStyle 配置）
const loginButtonStyle = computed(() => {
  const style = form.buttonStyle || 'filled'
  const primaryColor = form.buttonPrimaryColor || '#C41E3A'
  const gradientEndColor = form.buttonGradientEndColor || '#9A1830'
  const radius = form.buttonRadius || 'lg'

  // 圆角映射
  const radiusMap: Record<string, string> = {
    none: '0',
    sm: '8px',
    md: '12px',
    lg: '14px',
    full: '9999px',
  }
  const borderRadius = radiusMap[radius] || '14px'

  // 根据风格返回不同样式
  switch (style) {
    case 'outlined':
      return {
        background: 'transparent',
        border: `2px solid ${primaryColor}`,
        color: primaryColor,
        boxShadow: 'none',
        borderRadius,
      }
    case 'glass':
      return {
        background: 'rgba(255, 255, 255, 0.2)',
        backdropFilter: 'blur(10px)',
        border: '1px solid rgba(255, 255, 255, 0.3)',
        color: primaryColor,
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
        borderRadius,
      }
    case 'filled':
    default:
      return {
        background: `linear-gradient(135deg, ${primaryColor} 0%, ${gradientEndColor} 100%)`,
        border: 'none',
        color: '#ffffff',
        boxShadow: `0 4px 12px ${primaryColor}40`,
        borderRadius,
      }
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
      // 背景配置 - Aurora warm variant（3色渐变）
      backgroundType: data.backgroundType || 'gradient',
      backgroundImage: data.backgroundImage || '',
      backgroundColor: data.backgroundColor || '#FDF8F5',
      gradientStart: data.gradientStart || '#FDF8F5',
      gradientMiddle: data.gradientMiddle || '#F8F5F0',
      gradientEnd: data.gradientEnd || '#F5F0EB',
      gradientDirection: data.gradientDirection || 'to bottom',
      // Aurora 底纹配置
      auroraEnabled: data.auroraEnabled ?? true,
      auroraPreset: data.auroraPreset || 'warm',
      // Logo配置
      logoImage: data.logoImage || '',
      logoSize: data.logoSize || 'normal',
      logoAnimationEnabled: data.logoAnimationEnabled ?? true,
      // 应用名称配置
      appName: data.appName || '寻印',
      appNameColor: data.appNameColor || '#1a1a1a',
      // 标语配置
      slogan: data.slogan || '',
      sloganColor: data.sloganColor || '#666666',
      // 按钮样式
      buttonStyle: data.buttonStyle || 'filled',
      buttonPrimaryColor: data.buttonPrimaryColor || '#C41E3A',
      buttonGradientEndColor: data.buttonGradientEndColor || '#9A1830',
      buttonSecondaryColor: data.buttonSecondaryColor || 'rgba(196,30,58,0.08)',
      buttonRadius: data.buttonRadius || 'lg',
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
        }),
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
    <div class="flex gap-6 h-[calc(100vh-140px)]">
      <!-- 左侧：手机预览 -->
      <div class="shrink-0">
        <PhonePreview
          :scale="0.85"
          :show-device-switch="true"
          hint="预览效果（85% 缩放）"
          status-bar-color="black"
        >
          <template #default>
            <!-- Aurora 暖色渐变背景 -->
            <div
              class="w-full h-full flex flex-col relative overflow-hidden"
              :style="{
                background:
                  previewData.backgroundType === 'gradient'
                    ? `linear-gradient(${previewData.gradientDirection || 'to bottom'}, ${previewData.gradientStart || '#FDF8F5'} 0%, ${previewData.gradientMiddle || '#F8F5F0'} 50%, ${previewData.gradientEnd || '#F5F0EB'} 100%)`
                    : previewData.backgroundType === 'image' && previewData.backgroundImage
                      ? `url(${previewData.backgroundImage})`
                      : previewData.backgroundColor || '#FDF8F5',
                backgroundSize: 'cover',
                backgroundPosition: 'center',
              }"
            >
              <!-- Aurora 底纹光晕（根据预设动态渲染） -->
              <template v-if="previewData.auroraEnabled">
                <div
                  v-for="(circle, index) in auroraCircles"
                  :key="index"
                  class="absolute rounded-full pointer-events-none"
                  :style="{
                    width: circle.size,
                    height: circle.size,
                    top: circle.y,
                    left: circle.x,
                    transform: 'translate(-50%, -50%)',
                    backgroundColor: circle.color,
                    opacity: circle.opacity,
                  }"
                />
              </template>

              <!-- 主内容区域 -->
              <div class="flex-1 flex flex-col relative z-10 px-6">
                <!-- 顶部间距 - 增加以让内容整体下移 -->
                <div class="h-20 shrink-0" />

                <!-- Logo 区域（带浮动动画） -->
                <div
                  class="flex flex-col items-center"
                  :class="{ 'logo-float': previewData.logoAnimationEnabled }"
                >
                  <!-- 印章 Logo: 88x88px, 圆角 22px -->
                  <div
                    v-if="previewData.logoImage"
                    class="w-20 h-20 rounded-[18px] overflow-hidden"
                    :style="{
                      boxShadow: `0 8px 20px ${previewData.buttonPrimaryColor || '#C41E3A'}40`,
                    }"
                  >
                    <img
                      :src="previewData.logoImage"
                      class="w-full h-full object-cover"
                      alt="Logo"
                    />
                  </div>
                  <div
                    v-else
                    class="w-20 h-20 rounded-[18px] flex items-center justify-center"
                    :style="{
                      background: `linear-gradient(135deg, ${previewData.buttonPrimaryColor || '#C41E3A'} 0%, ${previewData.buttonPrimaryColor || '#C41E3A'}cc 100%)`,
                      boxShadow: `0 8px 20px ${previewData.buttonPrimaryColor || '#C41E3A'}40`,
                    }"
                  >
                    <span class="text-4xl font-bold text-white leading-none">印</span>
                  </div>
                  <!-- 间距 -->
                  <div class="h-4" />
                  <!-- 应用名称 -->
                  <h1
                    class="text-2xl font-bold"
                    :style="{
                      color: previewData.appNameColor || '#1a1a1a',
                      letterSpacing: '3px',
                    }"
                  >
                    {{ previewData.appName || '寻印' }}
                  </h1>
                  <!-- 间距 -->
                  <div class="h-1.5" />
                  <!-- 标语 -->
                  <p
                    class="text-xs"
                    :style="{
                      color: previewData.sloganColor || '#666666',
                      opacity: 0.8,
                      letterSpacing: '0.5px',
                    }"
                  >
                    {{ previewData.slogan || '探索城市文化，收集专属印记' }}
                  </p>
                </div>

                <!-- 间距 -->
                <div class="h-8 shrink-0" />

                <!-- 登录表单卡片 -->
                <div
                  class="rounded-2xl p-5"
                  :style="{
                    backgroundColor: 'rgba(255, 255, 255, 0.85)',
                    border: '1px solid rgba(255, 255, 255, 0.9)',
                    boxShadow: '0 8px 24px rgba(66, 80, 102, 0.06)',
                  }"
                >
                  <!-- 手机号输入框 -->
                  <div
                    class="flex items-center gap-3 rounded-xl px-4 py-3"
                    style="background-color: rgba(0, 0, 0, 0.04)"
                  >
                    <svg
                      class="w-5 h-5 text-gray-400 shrink-0"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="1.5"
                    >
                      <rect x="6" y="2" width="12" height="20" rx="2" />
                      <circle cx="12" cy="18" r="1" fill="currentColor" />
                    </svg>
                    <span class="text-gray-400 text-sm">请输入手机号</span>
                  </div>
                  <!-- 间距 -->
                  <div class="h-4" />
                  <!-- 验证码输入框 + 按钮 -->
                  <div class="flex items-center gap-2">
                    <div
                      class="flex-1 flex items-center gap-3 rounded-xl px-4 py-3 min-w-0"
                      style="background-color: rgba(0, 0, 0, 0.04)"
                    >
                      <svg
                        class="w-5 h-5 text-gray-400 shrink-0"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.5"
                      >
                        <rect x="3" y="11" width="18" height="11" rx="2" />
                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                      </svg>
                      <span class="text-gray-400 text-sm">验证码</span>
                    </div>
                    <!-- 验证码按钮 -->
                    <button
                      class="shrink-0 px-3 py-3 rounded-xl text-xs font-medium whitespace-nowrap"
                      :style="{
                        backgroundColor: `${previewData.buttonPrimaryColor || '#C41E3A'}14`,
                        color: previewData.buttonPrimaryColor || '#C41E3A',
                        border: `1px solid ${previewData.buttonPrimaryColor || '#C41E3A'}4d`,
                      }"
                    >
                      获取验证码
                    </button>
                  </div>
                </div>

                <!-- 间距 -->
                <div class="h-6 shrink-0" />

                <!-- 登录按钮 -->
                <button
                  class="w-full h-12 text-base font-semibold"
                  :style="{
                    ...loginButtonStyle,
                    letterSpacing: '2px',
                  }"
                >
                  登录
                </button>

                <!-- 间距 -->
                <div class="h-8 shrink-0" />

                <!-- 其他登录方式 -->
                <div>
                  <div class="flex items-center gap-3 mb-5">
                    <div class="flex-1 h-px" style="background-color: rgba(0, 0, 0, 0.1)" />
                    <span class="text-xs" style="color: rgba(0, 0, 0, 0.35)">其他登录方式</span>
                    <div class="flex-1 h-px" style="background-color: rgba(0, 0, 0, 0.1)" />
                  </div>
                  <!-- 社交登录图标 -->
                  <div class="flex justify-center gap-5">
                    <!-- 微信 -->
                    <div
                      v-if="previewData.wechatLoginEnabled"
                      class="flex flex-col items-center gap-1"
                    >
                      <div
                        class="w-12 h-12 rounded-xl flex items-center justify-center"
                        style="
                          background-color: rgba(0, 0, 0, 0.04);
                          border: 1px solid rgba(0, 0, 0, 0.08);
                        "
                      >
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="#07C160">
                          <path
                            d="M9.5 4C5.36 4 2 6.69 2 10c0 1.89 1.08 3.56 2.78 4.66l-.7 2.1 2.45-1.23c.89.26 1.85.47 2.97.47.34 0 .68-.02 1-.05-.19-.57-.3-1.17-.3-1.8 0-2.96 2.82-5.35 6.3-5.35.39 0 .77.03 1.14.08C16.83 5.96 13.53 4 9.5 4zm-2.25 3.5c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm4.5 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM16.5 10c-3.04 0-5.5 1.97-5.5 4.4s2.46 4.4 5.5 4.4c.68 0 1.34-.1 1.96-.28l1.79.9-.5-1.49c1.12-.87 1.75-2.05 1.75-3.53 0-2.43-2.46-4.4-5.5-4.4zm-2 2.75c.41 0 .75.34.75.75s-.34.75-.75.75-.75-.34-.75-.75.34-.75.75-.75zm4 0c.41 0 .75.34.75.75s-.34.75-.75.75-.75-.34-.75-.75.34-.75.75-.75z"
                          />
                        </svg>
                      </div>
                      <span class="text-[10px]" style="color: rgba(0, 0, 0, 0.5)">微信</span>
                    </div>
                    <!-- Apple -->
                    <div
                      v-if="previewData.appleLoginEnabled"
                      class="flex flex-col items-center gap-1"
                    >
                      <div
                        class="w-12 h-12 rounded-xl flex items-center justify-center"
                        style="
                          background-color: rgba(0, 0, 0, 0.04);
                          border: 1px solid rgba(0, 0, 0, 0.08);
                        "
                      >
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="#000000">
                          <path
                            d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
                          />
                        </svg>
                      </div>
                      <span class="text-[10px]" style="color: rgba(0, 0, 0, 0.5)">Apple</span>
                    </div>
                    <!-- Google -->
                    <div
                      v-if="previewData.googleLoginEnabled"
                      class="flex flex-col items-center gap-1"
                    >
                      <div
                        class="w-12 h-12 rounded-xl flex items-center justify-center"
                        style="
                          background-color: rgba(0, 0, 0, 0.04);
                          border: 1px solid rgba(0, 0, 0, 0.08);
                        "
                      >
                        <svg class="w-6 h-6" viewBox="0 0 24 24">
                          <path
                            fill="#4285F4"
                            d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                          />
                          <path
                            fill="#34A853"
                            d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                          />
                          <path
                            fill="#FBBC05"
                            d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                          />
                          <path
                            fill="#EA4335"
                            d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                          />
                        </svg>
                      </div>
                      <span class="text-[10px]" style="color: rgba(0, 0, 0, 0.5)">Google</span>
                    </div>
                  </div>
                </div>

                <!-- 弹性空间 - 把协议推到底部 -->
                <div class="flex-1" />

                <!-- 协议 - 固定在底部 -->
                <div class="text-center pb-6 shrink-0">
                  <p class="text-[11px]" style="color: rgba(0, 0, 0, 0.35)">
                    登录即表示同意<span
                      :style="{ color: `${previewData.buttonPrimaryColor || '#C41E3A'}e6` }"
                      >《用户协议》</span
                    >和<span :style="{ color: `${previewData.buttonPrimaryColor || '#C41E3A'}e6` }"
                      >《隐私政策》</span
                    >
                  </p>
                </div>
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
                      <Label>中间色</Label>
                      <div class="flex gap-2">
                        <input
                          type="color"
                          v-model="form.gradientMiddle"
                          class="w-10 h-10 rounded border cursor-pointer"
                        />
                        <Input v-model="form.gradientMiddle" class="flex-1" />
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

            <!-- Aurora 底纹配置 -->
            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">Aurora 底纹</CardTitle>
                <CardDescription class="text-xs">配置背景光晕效果，增加视觉层次</CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-sm font-medium">启用 Aurora 底纹</p>
                    <p class="text-xs text-muted-foreground">在背景上叠加柔和的光晕效果</p>
                  </div>
                  <Switch v-model:checked="form.auroraEnabled" />
                </div>
                <div v-if="form.auroraEnabled" class="space-y-2">
                  <Label>预设风格</Label>
                  <Select v-model="form.auroraPreset">
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="warm">暖色调（登录页推荐）</SelectItem>
                      <SelectItem value="standard">标准</SelectItem>
                      <SelectItem value="golden">金色调</SelectItem>
                      <SelectItem value="celebration">庆祝风格</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader class="py-3">
                <CardTitle class="text-sm">Logo 与应用名称</CardTitle>
                <CardDescription class="text-xs">配置登录页的 Logo、应用名称和标语</CardDescription>
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
                    <div class="flex items-center justify-between">
                      <div>
                        <p class="text-sm font-medium">Logo 浮动动画</p>
                        <p class="text-xs text-muted-foreground">上下浮动效果</p>
                      </div>
                      <Switch v-model:checked="form.logoAnimationEnabled" />
                    </div>
                  </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>应用名称</Label>
                    <Input v-model="form.appName" placeholder="寻印" />
                  </div>
                  <div class="space-y-2">
                    <Label>名称颜色</Label>
                    <div class="flex gap-2">
                      <input
                        type="color"
                        v-model="form.appNameColor"
                        class="w-10 h-10 rounded border cursor-pointer"
                      />
                      <Input v-model="form.appNameColor" class="flex-1" />
                    </div>
                  </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <Label>标语</Label>
                    <Input v-model="form.slogan" placeholder="探索城市文化，收集专属印记" />
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
                    <Label>渐变起始色</Label>
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
                    <Label>渐变结束色</Label>
                    <div class="flex gap-2">
                      <input
                        type="color"
                        v-model="form.buttonGradientEndColor"
                        class="w-10 h-10 rounded border cursor-pointer"
                      />
                      <Input v-model="form.buttonGradientEndColor" class="flex-1" />
                    </div>
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
/* Logo 浮动动画 */
@keyframes logo-float {
  0%,
  100% {
    transform: translateY(-4px);
  }
  50% {
    transform: translateY(4px);
  }
}

.logo-float {
  animation: logo-float 2s ease-in-out infinite;
}
</style>
