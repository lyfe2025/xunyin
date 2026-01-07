<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useToast } from '@/components/ui/toast/use-toast'
import ImageUpload from '@/components/common/ImageUpload.vue'
import LeaveConfirmDialog from '@/components/common/LeaveConfirmDialog.vue'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import { listConfig, updateConfig, addConfig, type SysConfig } from '@/api/system/config'
import { getDictDataByType, type DictData } from '@/api/system/dict'
import { testMail } from '@/api/system/mail'
import { getLockedAccounts, unlockAccount, type LockedAccount } from '@/api/system/locked'
import { useAppStore } from '@/stores/modules/app'
import { useUnsavedChanges } from '@/composables'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import {
  Save,
  RefreshCw,
  Shield,
  Globe,
  Mail,
  HardDrive,
  Clock,
  Send,
  Lock,
  Unlock,
  HelpCircle,
  ChevronDown,
  Link2,
  KeyRound,
} from 'lucide-vue-next'

const { toast } = useToast()
const appStore = useAppStore()
const route = useRoute()

// 当前激活的 tab，支持通过 query 参数指定
const activeTab = ref((route.query.tab as string) || 'site')

// 区块链存证服务提供者选项（从字典获取）
const chainProviderOptions = ref<DictData[]>([])

// 监听路由参数变化，切换到对应标签页
watch(
  () => route.query.tab,
  (newTab) => {
    if (newTab && typeof newTab === 'string') {
      activeTab.value = newTab
    }
  },
)

// 未保存更改提示（页面级表单，启用路由守卫）
const { isDirty, markClean, showLeaveDialog, confirmLeave, cancelLeave } = useUnsavedChanges()

const loading = ref(false)
const submitLoading = ref(false)
const testMailLoading = ref(false)
const configList = ref<SysConfig[]>([])
const lockedAccounts = ref<LockedAccount[]>([])
const lockedLoading = ref(false)

const form = reactive({
  // 网站设置
  'sys.app.name': '',
  'sys.app.description': '',
  'sys.app.copyright': '',
  'sys.app.icp': '',
  'sys.app.email': '',
  'sys.app.logo': '',
  'sys.app.favicon': '',
  // 安全设置
  'sys.account.captchaEnabled': 'false',
  'sys.account.twoFactorEnabled': 'false',

  // 安全入口
  'sys.security.loginPath': '/login',
  // 登录限制
  'sys.login.maxRetry': '5',
  'sys.login.lockTime': '10',
  // 会话设置
  'sys.session.timeout': '30',
  // 邮件设置
  'sys.mail.enabled': 'false',
  'sys.mail.host': '',
  'sys.mail.port': '465',
  'sys.mail.username': '',
  'sys.mail.password': '',
  'sys.mail.from': '',
  'sys.mail.ssl': 'true',
  // 存储设置
  'sys.storage.type': 'local',
  'sys.storage.local.path': './uploads',
  'sys.storage.oss.endpoint': '',
  'sys.storage.oss.bucket': '',
  'sys.storage.oss.accessKey': '',
  'sys.storage.oss.secretKey': '',

  // ========== 三方登录配置 ==========
  // 微信登录
  'oauth.wechat.enabled': 'false',
  'oauth.wechat.appId': '',
  'oauth.wechat.appSecret': '',
  // Google登录
  'oauth.google.enabled': 'false',
  'oauth.google.clientId': '',
  'oauth.google.clientSecret': '',
  // Apple登录
  'oauth.apple.enabled': 'false',
  'oauth.apple.teamId': '',
  'oauth.apple.clientId': '',
  'oauth.apple.keyId': '',
  'oauth.apple.privateKey': '',

  // ========== 地图配置 ==========
  // 高德地图
  'map.amap.enabled': 'true',
  'map.amap.webKey': '',
  'map.amap.webSecurityKey': '',
  'map.amap.androidKey': '',
  'map.amap.iosKey': '',
  // 腾讯地图
  'map.tencent.enabled': 'false',
  'map.tencent.key': '',
  // Google地图
  'map.google.enabled': 'false',
  'map.google.key': '',

  // ========== 区块链存证配置 ==========
  'chain.provider': 'local',
  'chain.timestamp.apiKey': '',
  'chain.timestamp.endpoint': 'https://tsa.example.com/timestamp',
  'chain.antchain.appId': '',
  'chain.antchain.privateKey': '',
  'chain.antchain.endpoint': 'https://rest.antchain.alipay.com',
  'chain.zhixin.secretId': '',
  'chain.zhixin.secretKey': '',
  'chain.zhixin.endpoint': 'https://tbaas.tencentcloudapi.com',
  'chain.bsn.apiKey': '',
  'chain.bsn.projectId': '',
  'chain.bsn.endpoint': 'https://api.bsngate.com',
  'chain.polygon.rpcUrl': 'https://polygon-rpc.com',
  'chain.polygon.privateKey': '',
  'chain.polygon.contractAddress': '',
})

const configMap = ref<Record<string, SysConfig>>({})

// 监听表单变化，标记脏状态（数据加载完成后才开始监听）
const isDataLoaded = ref(false)
const isInitializing = ref(false) // 防止初始化时触发脏状态
watch(
  () => ({ ...form }),
  () => {
    if (isDataLoaded.value && !isInitializing.value) {
      isDirty.value = true
    }
  },
  { deep: true },
)

async function getData() {
  loading.value = true
  isInitializing.value = true // 开始初始化
  try {
    // 获取区块链存证服务提供者字典数据
    const chainOptions = await getDictDataByType('xunyin_chain_name')
    chainProviderOptions.value = chainOptions

    const prefixes = [
      'sys.app.',
      'sys.account.',
      'sys.security.',
      'sys.login.',
      'sys.session.',
      'sys.mail.',
      'sys.storage.',
      'oauth.',
      'map.',
      'chain.',
    ]
    const results = await Promise.all(
      prefixes.map((p) => listConfig({ configKey: p, pageSize: 50 })),
    )
    configList.value = results.flatMap((r) => r.rows ?? [])
    // 重置 configMap
    configMap.value = {}
    configList.value.forEach((item: SysConfig) => {
      // 确保 configValue 是字符串
      const value = String(item.configValue ?? '')
      configMap.value[item.configKey] = { ...item, configValue: value }
      if (item.configKey in form) {
        ;(form as any)[item.configKey] = value
      }
    })
    // 等待下一个 tick，确保所有 watch 都执行完毕
    await new Promise((resolve) => setTimeout(resolve, 0))
    // 数据加载完成后，清除脏状态并开始监听
    markClean()
    isDataLoaded.value = true
  } finally {
    loading.value = false
    isInitializing.value = false // 初始化结束
  }
}

async function handleSubmit() {
  // 校验所有字段
  if (hasValidationError.value) {
    const firstError = Object.values(formErrors).find((e) => e !== '')
    toast({
      title: '保存失败',
      description: firstError || '请检查表单填写',
      variant: 'destructive',
    })
    return
  }

  submitLoading.value = true

  try {
    const updates: Promise<any>[] = []
    for (const [key, value] of Object.entries(form)) {
      const originalConfig = configMap.value[key]
      if (originalConfig) {
        // 配置已存在，检查是否有变化（都转为字符串比较）
        const originalValue = String(originalConfig.configValue ?? '')
        const newValue = String(value ?? '')
        if (originalValue !== newValue) {
          updates.push(updateConfig({ ...originalConfig, configValue: newValue }))
        }
      } else {
        // 配置不存在，创建新配置
        updates.push(
          addConfig({
            configName: getConfigName(key),
            configKey: key,
            configValue: value,
            configType: 'Y',
            remark: getConfigRemark(key),
          }),
        )
      }
    }

    if (updates.length === 0) {
      toast({ title: '无需保存', description: '配置未发生变化' })
      return
    }

    const results = await Promise.allSettled(updates)
    const failed = results.filter((r) => r.status === 'rejected')
    if (failed.length > 0) {
      console.error('部分配置保存失败:', failed)
      toast({
        title: '部分保存失败',
        description: `${updates.length - failed.length}/${updates.length} 项保存成功`,
        variant: 'destructive',
      })
    } else {
      toast({ title: '保存成功', description: '系统设置已更新' })
      markClean() // 保存成功后清除脏状态
      // 刷新网站配置使其立即生效
      await appStore.refreshSiteConfig()
    }
    await getData()
  } catch (error) {
    console.error('保存失败:', error)
    toast({ title: '保存失败', description: '请稍后重试', variant: 'destructive' })
  } finally {
    submitLoading.value = false
  }
}

async function handleTestMail() {
  // 先保存当前配置
  await handleSubmit()

  testMailLoading.value = true
  try {
    const res = (await testMail()) as unknown as { data: { success: boolean; message: string } }
    const result = res.data
    if (result.success) {
      toast({ title: '发送成功', description: result.message || '测试邮件已发送，请检查收件箱' })
    } else {
      toast({
        title: '发送失败',
        description: result.message || '请检查邮件配置',
        variant: 'destructive',
      })
    }
  } catch (error: any) {
    toast({
      title: '发送失败',
      description: error?.message || '请检查邮件配置',
      variant: 'destructive',
    })
  } finally {
    testMailLoading.value = false
  }
}

function getConfigName(key: string): string {
  const names: Record<string, string> = {
    'sys.app.name': '网站名称',
    'sys.app.description': '网站描述',
    'sys.app.copyright': '版权信息',
    'sys.app.icp': 'ICP备案号',
    'sys.app.email': '联系邮箱',
    'sys.app.logo': '网站Logo',
    'sys.app.favicon': '网站图标',
    'sys.account.captchaEnabled': '验证码开关',
    'sys.account.twoFactorEnabled': '两步验证开关',
    'sys.security.loginPath': '安全登录路径',
    'sys.login.maxRetry': '登录失败次数',
    'sys.login.lockTime': '账户锁定时长',
    'sys.session.timeout': '会话超时时间',
    'sys.mail.enabled': '邮件服务开关',
    'sys.mail.host': 'SMTP服务器',
    'sys.mail.port': 'SMTP端口',
    'sys.mail.username': '邮箱账号',
    'sys.mail.password': '邮箱密码',
    'sys.mail.from': '发件人地址',
    'sys.mail.ssl': 'SSL/TLS开关',
    'sys.storage.type': '存储类型',
    'sys.storage.local.path': '本地存储路径',
    'sys.storage.oss.endpoint': 'OSS端点',
    'sys.storage.oss.bucket': 'OSS存储桶',
    'sys.storage.oss.accessKey': 'OSS AccessKey',
    'sys.storage.oss.secretKey': 'OSS SecretKey',
    // 三方登录
    'oauth.wechat.enabled': '微信登录开关',
    'oauth.wechat.appId': '微信AppID',
    'oauth.wechat.appSecret': '微信AppSecret',
    'oauth.google.enabled': 'Google登录开关',
    'oauth.google.clientId': 'Google Client ID',
    'oauth.google.clientSecret': 'Google Client Secret',
    'oauth.apple.enabled': 'Apple登录开关',
    'oauth.apple.teamId': 'Apple Team ID',
    'oauth.apple.clientId': 'Apple Client ID',
    'oauth.apple.keyId': 'Apple Key ID',
    'oauth.apple.privateKey': 'Apple Private Key',
    // 地图配置
    'map.amap.enabled': '高德地图开关',
    'map.amap.webKey': '高德Web服务Key',
    'map.amap.webSecurityKey': '高德Web安全密钥',
    'map.amap.androidKey': '高德Android Key',
    'map.amap.iosKey': '高德iOS Key',
    'map.tencent.enabled': '腾讯地图开关',
    'map.tencent.key': '腾讯地图Key',
    'map.google.enabled': 'Google地图开关',
    'map.google.key': 'Google地图Key',
    // 区块链存证
    'chain.provider': '链服务提供者',
    'chain.antchain.appId': '蚂蚁链AppID',
    'chain.antchain.privateKey': '蚂蚁链私钥',
    'chain.antchain.endpoint': '蚂蚁链端点',
    'chain.bsn.apiKey': 'BSN API Key',
    'chain.bsn.projectId': 'BSN项目ID',
    'chain.bsn.endpoint': 'BSN端点',
    'chain.polygon.rpcUrl': 'Polygon RPC URL',
    'chain.polygon.privateKey': 'Polygon私钥',
    'chain.polygon.contractAddress': 'Polygon合约地址',
  }
  return names[key] || key
}

function getConfigRemark(key: string): string {
  const remarks: Record<string, string> = {
    'sys.security.loginPath': '自定义管理后台登录页路径，增强安全性',
    'sys.login.maxRetry': '连续登录失败次数达到后锁定账户',
    'sys.login.lockTime': '账户锁定时长（分钟）',
    'sys.session.timeout': 'Token有效期（分钟）',
    'sys.mail.ssl': '是否启用SSL/TLS加密连接',
  }
  return remarks[key] || ''
}

function handleReset() {
  getData()
  toast({ title: '已重置', description: '表单已恢复为当前配置' })
}

// 为每个 Switch 创建计算属性，处理字符串和布尔值的转换
const captchaEnabled = computed({
  get: () => form['sys.account.captchaEnabled'] === 'true',
  set: (val: boolean) => {
    form['sys.account.captchaEnabled'] = val ? 'true' : 'false'
  },
})

const twoFactorEnabled = computed({
  get: () => form['sys.account.twoFactorEnabled'] === 'true',
  set: (val: boolean) => {
    form['sys.account.twoFactorEnabled'] = val ? 'true' : 'false'
  },
})

// 登录路径输入（不含前缀 /）
const loginPathInput = ref('')

// 表单校验错误
const formErrors = reactive({
  loginPath: '',
  email: '',
  maxRetry: '',
  lockTime: '',
  sessionTimeout: '',
  mailPort: '',
  mailFrom: '',
})

// 校验函数
const validators = {
  loginPath(value: string): string {
    if (!value) return ''
    if (!/^[a-zA-Z0-9_-]+$/.test(value)) {
      return '只允许字母、数字、中划线(-)、下划线(_)'
    }
    if (value.length < 2 || value.length > 50) {
      return '长度需在 2-50 个字符之间'
    }
    return ''
  },
  email(value: string): string {
    if (!value) return ''
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
      return '邮箱格式不正确'
    }
    return ''
  },
  positiveInt(value: string, min: number, max: number, label: string): string {
    if (!value) return ''
    const num = parseInt(value, 10)
    if (isNaN(num) || num < min || num > max) {
      return `${label}需在 ${min}-${max} 之间`
    }
    return ''
  },
  port(value: string): string {
    if (!value) return ''
    const num = parseInt(value, 10)
    if (isNaN(num) || num < 1 || num > 65535) {
      return '端口需在 1-65535 之间'
    }
    return ''
  },
}

// 是否有校验错误
const hasValidationError = computed(() => {
  return Object.values(formErrors).some((e) => e !== '')
})

// 监听输入变化，实时校验并同步到 form
watch(loginPathInput, (val) => {
  formErrors.loginPath = validators.loginPath(val)
  // 只在非初始化阶段同步到 form
  if (!isInitializing.value) {
    form['sys.security.loginPath'] = val ? `/${val}` : '/login'
  }
})

// 从 form 初始化 loginPathInput（去掉前缀 /）
watch(
  () => form['sys.security.loginPath'],
  (val) => {
    const path = val?.startsWith('/') ? val.slice(1) : val
    if (path !== loginPathInput.value) {
      loginPathInput.value = path || ''
    }
  },
  { immediate: true },
)

// 监听其他字段校验
watch(
  () => form['sys.app.email'],
  (val) => {
    formErrors.email = validators.email(val)
  },
)
watch(
  () => form['sys.login.maxRetry'],
  (val) => {
    formErrors.maxRetry = validators.positiveInt(val, 1, 10, '失败锁定次数')
  },
)
watch(
  () => form['sys.login.lockTime'],
  (val) => {
    formErrors.lockTime = validators.positiveInt(val, 1, 1440, '锁定时长')
  },
)
watch(
  () => form['sys.session.timeout'],
  (val) => {
    formErrors.sessionTimeout = validators.positiveInt(val, 5, 10080, '会话超时')
  },
)
watch(
  () => form['sys.mail.port'],
  (val) => {
    formErrors.mailPort = validators.port(val)
  },
)
watch(
  () => form['sys.mail.from'],
  (val) => {
    // 仅在启用邮件时校验
    if (form['sys.mail.enabled'] === 'true' && val) {
      formErrors.mailFrom = validators.email(val)
    } else {
      formErrors.mailFrom = ''
    }
  },
)

const mailEnabled = computed({
  get: () => form['sys.mail.enabled'] === 'true',
  set: (val: boolean) => {
    form['sys.mail.enabled'] = val ? 'true' : 'false'
  },
})

// 地图开关
const amapEnabled = computed({
  get: () => form['map.amap.enabled'] === 'true',
  set: (val: boolean) => {
    form['map.amap.enabled'] = val ? 'true' : 'false'
  },
})
const tencentMapEnabled = computed({
  get: () => form['map.tencent.enabled'] === 'true',
  set: (val: boolean) => {
    form['map.tencent.enabled'] = val ? 'true' : 'false'
  },
})
const googleMapEnabled = computed({
  get: () => form['map.google.enabled'] === 'true',
  set: (val: boolean) => {
    form['map.google.enabled'] = val ? 'true' : 'false'
  },
})

// 加载被锁定的账户列表
async function loadLockedAccounts() {
  lockedLoading.value = true
  try {
    const res = (await getLockedAccounts()) as unknown as {
      data: { rows: LockedAccount[]; total: number }
    }
    lockedAccounts.value = res.data?.rows || []
  } catch (error) {
    console.error('获取锁定账户失败:', error)
  } finally {
    lockedLoading.value = false
  }
}

// 解锁账户
async function handleUnlock(username: string) {
  try {
    await unlockAccount(username)
    toast({ title: '解锁成功', description: `账户 ${username} 已解锁` })
    await loadLockedAccounts()
  } catch {
    toast({ title: '解锁失败', description: '请稍后重试', variant: 'destructive' })
  }
}

onMounted(() => {
  getData()
  loadLockedAccounts()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">系统设置</h2>
        <p class="text-muted-foreground">管理系统的各项配置参数</p>
      </div>
      <div class="flex gap-2">
        <Button variant="outline" @click="handleReset" :disabled="submitLoading">
          <RefreshCw class="mr-2 h-4 w-4" />重置
        </Button>
        <Button @click="handleSubmit" :disabled="submitLoading">
          <Save class="mr-2 h-4 w-4" />保存设置
        </Button>
      </div>
    </div>

    <Tabs v-model="activeTab" class="space-y-4">
      <TabsList class="flex-wrap h-auto gap-1">
        <TabsTrigger value="site"><Globe class="h-4 w-4 mr-2" />网站设置</TabsTrigger>
        <TabsTrigger value="security"><Shield class="h-4 w-4 mr-2" />安全设置</TabsTrigger>
        <TabsTrigger value="mail"><Mail class="h-4 w-4 mr-2" />邮件设置</TabsTrigger>
        <TabsTrigger value="storage"><HardDrive class="h-4 w-4 mr-2" />存储设置</TabsTrigger>
        <TabsTrigger value="map"><Globe class="h-4 w-4 mr-2" />地图配置</TabsTrigger>
        <TabsTrigger value="chain"><Link2 class="h-4 w-4 mr-2" />区块链存证</TabsTrigger>
      </TabsList>

      <!-- 网站设置 -->
      <TabsContent value="site" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>基本信息</CardTitle>
            <CardDescription>配置网站的公开展示信息</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>网站名称</Label>
                <Input v-model="form['sys.app.name']" placeholder="请输入网站名称" />
              </div>
              <div class="grid gap-2">
                <Label>联系邮箱</Label>
                <Input
                  v-model="form['sys.app.email']"
                  placeholder="support@example.com"
                  :class="{ 'border-destructive focus-visible:ring-destructive': formErrors.email }"
                />
                <p v-if="formErrors.email" class="text-xs text-destructive">
                  {{ formErrors.email }}
                </p>
              </div>
            </div>
            <div class="grid gap-2">
              <Label>网站描述</Label>
              <Textarea
                v-model="form['sys.app.description']"
                placeholder="请输入网站描述"
                rows="2"
              />
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>网站 Logo</Label>
                <ImageUpload
                  v-model="form['sys.app.logo']"
                  accept=".png,.jpg,.jpeg,.svg,image/png,image/jpeg,image/svg+xml"
                />
                <p class="text-xs text-muted-foreground">
                  建议高度 32-40px，正方形或横向均可，支持 PNG/JPG/SVG
                </p>
              </div>
              <div class="grid gap-2">
                <Label>网站 Favicon</Label>
                <ImageUpload
                  v-model="form['sys.app.favicon']"
                  accept=".ico,.png,image/png,image/x-icon"
                />
                <p class="text-xs text-muted-foreground">
                  建议尺寸 32x32px 或 16x16px，支持 ICO/PNG
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>页脚信息</CardTitle>
            <CardDescription>配置网站底部的版权和备案信息</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid gap-2">
              <Label>版权信息</Label>
              <Input
                v-model="form['sys.app.copyright']"
                placeholder="© 2025 Xunyin. All rights reserved."
              />
            </div>
            <div class="grid gap-2">
              <Label>ICP 备案号</Label>
              <Input v-model="form['sys.app.icp']" placeholder="例如：京ICP备12345678号" />
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 安全设置 -->
      <TabsContent value="security" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2"
              ><KeyRound class="h-5 w-5" />安全入口</CardTitle
            >
            <CardDescription>配置管理后台的登录页访问路径，隐藏默认入口增强安全性</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid gap-2">
              <Label>登录页路径</Label>
              <div class="flex">
                <span
                  class="inline-flex items-center px-3 rounded-l-md border border-r-0 border-input bg-muted text-muted-foreground text-sm"
                  >/</span
                >
                <Input
                  v-model="loginPathInput"
                  placeholder="login"
                  class="rounded-l-none"
                  :class="{
                    'border-destructive focus-visible:ring-destructive': formErrors.loginPath,
                  }"
                />
              </div>
              <p v-if="formErrors.loginPath" class="text-xs text-destructive">
                {{ formErrors.loginPath }}
              </p>
              <p class="text-xs text-muted-foreground">
                自定义登录页访问路径，例如：admin-login、secure-entry
                等。修改后需要使用新路径访问登录页。
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>登录安全</CardTitle>
            <CardDescription>配置用户登录相关的安全选项</CardDescription>
          </CardHeader>
          <CardContent class="space-y-6">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div class="space-y-0.5">
                <Label class="text-base flex items-center gap-2"
                  ><KeyRound class="h-4 w-4" />登录验证码</Label
                >
                <p class="text-sm text-muted-foreground">开启后，用户登录时需要输入图形验证码</p>
              </div>
              <Switch v-model:checked="captchaEnabled" />
            </div>
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div class="space-y-0.5">
                <Label class="text-base flex items-center gap-2"
                  ><Shield class="h-4 w-4" />两步验证</Label
                >
                <p class="text-sm text-muted-foreground">
                  开启后，用户可以绑定手机或邮箱进行二次验证
                </p>
              </div>
              <Switch v-model:checked="twoFactorEnabled" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2"
              ><Clock class="h-5 w-5" />登录限制与会话</CardTitle
            >
            <CardDescription>配置登录失败锁定和会话超时</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="grid gap-2">
                <Label>失败锁定次数</Label>
                <Input
                  v-model="form['sys.login.maxRetry']"
                  type="number"
                  min="1"
                  max="10"
                  :class="{
                    'border-destructive focus-visible:ring-destructive': formErrors.maxRetry,
                  }"
                />
                <p v-if="formErrors.maxRetry" class="text-xs text-destructive">
                  {{ formErrors.maxRetry }}
                </p>
                <p v-else class="text-xs text-muted-foreground">连续失败N次后锁定</p>
              </div>
              <div class="grid gap-2">
                <Label>锁定时长（分钟）</Label>
                <Input
                  v-model="form['sys.login.lockTime']"
                  type="number"
                  min="1"
                  :class="{
                    'border-destructive focus-visible:ring-destructive': formErrors.lockTime,
                  }"
                />
                <p v-if="formErrors.lockTime" class="text-xs text-destructive">
                  {{ formErrors.lockTime }}
                </p>
              </div>
              <div class="grid gap-2">
                <Label>会话超时（分钟）</Label>
                <Input
                  v-model="form['sys.session.timeout']"
                  type="number"
                  min="5"
                  :class="{
                    'border-destructive focus-visible:ring-destructive': formErrors.sessionTimeout,
                  }"
                />
                <p v-if="formErrors.sessionTimeout" class="text-xs text-destructive">
                  {{ formErrors.sessionTimeout }}
                </p>
                <p v-else class="text-xs text-muted-foreground">无操作超过此时间后自动退出</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2">
              <Lock class="h-5 w-5" />锁定账户管理
              <Button
                variant="ghost"
                size="icon"
                class="h-6 w-6 ml-auto"
                @click="loadLockedAccounts"
                :disabled="lockedLoading"
              >
                <RefreshCw class="h-4 w-4" :class="{ 'animate-spin': lockedLoading }" />
              </Button>
            </CardTitle>
            <CardDescription>查看和解锁因登录失败被锁定的账户</CardDescription>
          </CardHeader>
          <CardContent>
            <div v-if="lockedLoading" class="text-center py-4 text-muted-foreground">加载中...</div>
            <div
              v-else-if="lockedAccounts.length === 0"
              class="text-center py-4 text-muted-foreground"
            >
              暂无被锁定的账户
            </div>
            <div v-else class="space-y-2">
              <div
                v-for="account in lockedAccounts"
                :key="account.username"
                class="flex items-center justify-between p-3 rounded-lg border bg-muted/50"
              >
                <div class="flex items-center gap-3">
                  <Lock class="h-4 w-4 text-destructive" />
                  <div>
                    <p class="font-medium">{{ account.username }}</p>
                    <p class="text-xs text-muted-foreground">
                      剩余锁定时间：{{ Math.ceil(account.remainingSeconds / 60) }} 分钟
                    </p>
                  </div>
                </div>
                <Button variant="outline" size="sm" @click="handleUnlock(account.username)">
                  <Unlock class="h-4 w-4 mr-1" />解锁
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 邮件设置 -->
      <TabsContent value="mail" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>SMTP 配置</CardTitle>
            <CardDescription>配置邮件发送服务，用于发送验证码、通知等邮件</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="flex items-center justify-between pb-4 border-b">
              <div class="space-y-0.5">
                <Label class="text-base">启用邮件服务</Label>
                <p class="text-sm text-muted-foreground">开启后系统可发送邮件通知</p>
              </div>
              <Switch v-model:checked="mailEnabled" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="grid gap-2">
                <Label class="flex items-center gap-2">
                  SMTP 服务器
                  <Collapsible class="inline">
                    <CollapsibleTrigger as-child>
                      <button
                        type="button"
                        class="inline-flex items-center text-muted-foreground hover:text-foreground transition-colors"
                      >
                        <HelpCircle class="h-4 w-4" />
                      </button>
                    </CollapsibleTrigger>
                    <CollapsibleContent
                      class="absolute z-10 mt-2 w-80 rounded-lg border bg-popover p-3 text-sm shadow-md"
                    >
                      <p class="font-medium mb-2">常用邮箱 SMTP 配置：</p>
                      <ul class="text-muted-foreground space-y-1 text-xs">
                        <li>
                          <span class="text-foreground">QQ：</span>smtp.qq.com:465，<a
                            href="https://service.mail.qq.com/detail/0/75"
                            target="_blank"
                            class="text-primary hover:underline"
                            >获取授权码</a
                          >
                        </li>
                        <li><span class="text-foreground">163：</span>smtp.163.com:465</li>
                        <li>
                          <span class="text-foreground">Gmail：</span>smtp.gmail.com:465，<a
                            href="https://support.google.com/accounts/answer/185833"
                            target="_blank"
                            class="text-primary hover:underline"
                            >应用密码</a
                          >
                        </li>
                        <li>
                          <span class="text-foreground">Outlook：</span>smtp.office365.com:587
                        </li>
                        <li>
                          <span class="text-foreground">阿里企业：</span>smtp.qiye.aliyun.com:465
                        </li>
                      </ul>
                    </CollapsibleContent>
                  </Collapsible>
                </Label>
                <Input v-model="form['sys.mail.host']" placeholder="smtp.qq.com" />
              </div>
              <div class="grid gap-2">
                <Label>SMTP 端口</Label>
                <Input
                  v-model="form['sys.mail.port']"
                  placeholder="465"
                  :class="{
                    'border-destructive focus-visible:ring-destructive': formErrors.mailPort,
                  }"
                />
                <p v-if="formErrors.mailPort" class="text-xs text-destructive">
                  {{ formErrors.mailPort }}
                </p>
              </div>
              <div class="grid gap-2">
                <Label>SSL/TLS</Label>
                <Select v-model="form['sys.mail.ssl']">
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="true">启用 SSL</SelectItem>
                    <SelectItem value="false">不启用</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>邮箱账号</Label>
                <Input v-model="form['sys.mail.username']" placeholder="登录邮箱账号" />
                <p class="text-xs text-muted-foreground">用于登录 SMTP 服务器的认证账号</p>
              </div>
              <div class="grid gap-2">
                <Label>邮箱密码/授权码</Label>
                <Input
                  v-model="form['sys.mail.password']"
                  type="password"
                  placeholder="邮箱密码或授权码"
                />
                <p class="text-xs text-muted-foreground">QQ/163 等邮箱需使用授权码，非登录密码</p>
              </div>
            </div>

            <div class="grid gap-2">
              <Label>发件人地址</Label>
              <Input
                v-model="form['sys.mail.from']"
                placeholder="noreply@example.com"
                :class="{
                  'border-destructive focus-visible:ring-destructive': formErrors.mailFrom,
                }"
              />
              <p v-if="formErrors.mailFrom" class="text-xs text-destructive">
                {{ formErrors.mailFrom }}
              </p>
              <p v-else class="text-xs text-muted-foreground">
                收件人看到的发件人，QQ 邮箱需与账号一致
              </p>
            </div>

            <div class="pt-4 border-t">
              <Button variant="outline" @click="handleTestMail" :disabled="testMailLoading">
                <Send class="mr-2 h-4 w-4" />测试发送
              </Button>
              <p class="text-xs text-muted-foreground mt-2">
                发送测试邮件到发件人地址，验证配置是否正确
              </p>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 存储设置 -->
      <TabsContent value="storage" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>文件存储</CardTitle>
            <CardDescription>配置系统文件的存储方式，支持本地存储和多种云存储服务</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid gap-2">
              <Label>存储类型</Label>
              <Select v-model="form['sys.storage.type']">
                <SelectTrigger><SelectValue placeholder="选择存储类型" /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="local">本地存储</SelectItem>
                  <SelectItem value="s3">AWS S3</SelectItem>
                  <SelectItem value="gcs">Google Cloud Storage</SelectItem>
                  <SelectItem value="oss">阿里云 OSS</SelectItem>
                  <SelectItem value="cos">腾讯云 COS</SelectItem>
                  <SelectItem value="r2">Cloudflare R2</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div v-if="form['sys.storage.type'] === 'local'" class="grid gap-2">
              <Label>存储路径</Label>
              <Input v-model="form['sys.storage.local.path']" placeholder="./uploads" />
              <p class="text-xs text-muted-foreground">
                文件存储的本地目录路径，相对于后端项目根目录
              </p>
            </div>

            <div v-else class="space-y-4">
              <!-- 云存储配置说明 - 可折叠 -->
              <Collapsible>
                <CollapsibleTrigger as-child>
                  <button
                    type="button"
                    class="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors group"
                  >
                    <HelpCircle class="h-4 w-4" />
                    <span>如何获取 {{ form['sys.storage.type'].toUpperCase() }} 配置？</span>
                    <ChevronDown
                      class="h-4 w-4 transition-transform group-data-[state=open]:rotate-180"
                    />
                  </button>
                </CollapsibleTrigger>
                <CollapsibleContent>
                  <div class="rounded-lg bg-muted/50 p-3 text-sm mt-2">
                    <ul
                      v-if="form['sys.storage.type'] === 's3'"
                      class="text-muted-foreground space-y-1 text-xs"
                    >
                      <li>
                        1. 登录
                        <a
                          href="https://console.aws.amazon.com/s3"
                          target="_blank"
                          class="text-primary hover:underline"
                          >AWS S3 控制台</a
                        >
                        创建存储桶
                      </li>
                      <li>
                        2. Endpoint：<code class="bg-muted px-1 rounded"
                          >s3.{region}.amazonaws.com</code
                        >
                      </li>
                      <li>
                        3. 在
                        <a
                          href="https://console.aws.amazon.com/iam"
                          target="_blank"
                          class="text-primary hover:underline"
                          >IAM</a
                        >
                        创建用户获取 AccessKey
                      </li>
                    </ul>
                    <ul
                      v-else-if="form['sys.storage.type'] === 'gcs'"
                      class="text-muted-foreground space-y-1 text-xs"
                    >
                      <li>
                        1. 登录
                        <a
                          href="https://console.cloud.google.com/storage"
                          target="_blank"
                          class="text-primary hover:underline"
                          >Google Cloud Console</a
                        >
                        创建存储桶
                      </li>
                      <li>
                        2. Endpoint：<code class="bg-muted px-1 rounded"
                          >storage.googleapis.com</code
                        >
                      </li>
                      <li>3. 创建服务账号，生成 HMAC 密钥</li>
                    </ul>
                    <ul
                      v-else-if="form['sys.storage.type'] === 'oss'"
                      class="text-muted-foreground space-y-1 text-xs"
                    >
                      <li>
                        1. 登录
                        <a
                          href="https://oss.console.aliyun.com"
                          target="_blank"
                          class="text-primary hover:underline"
                          >阿里云 OSS 控制台</a
                        >
                        创建 Bucket
                      </li>
                      <li>
                        2. Endpoint：<code class="bg-muted px-1 rounded"
                          >oss-{region}.aliyuncs.com</code
                        >
                      </li>
                      <li>
                        3. 在
                        <a
                          href="https://ram.console.aliyun.com"
                          target="_blank"
                          class="text-primary hover:underline"
                          >RAM</a
                        >
                        创建用户获取 AccessKey
                      </li>
                    </ul>
                    <ul
                      v-else-if="form['sys.storage.type'] === 'cos'"
                      class="text-muted-foreground space-y-1 text-xs"
                    >
                      <li>
                        1. 登录
                        <a
                          href="https://console.cloud.tencent.com/cos"
                          target="_blank"
                          class="text-primary hover:underline"
                          >腾讯云 COS 控制台</a
                        >
                        创建存储桶
                      </li>
                      <li>
                        2. Endpoint：<code class="bg-muted px-1 rounded"
                          >cos.{region}.myqcloud.com</code
                        >
                      </li>
                      <li>
                        3. 在
                        <a
                          href="https://console.cloud.tencent.com/cam"
                          target="_blank"
                          class="text-primary hover:underline"
                          >CAM</a
                        >
                        创建子用户获取密钥
                      </li>
                    </ul>
                    <ul
                      v-else-if="form['sys.storage.type'] === 'r2'"
                      class="text-muted-foreground space-y-1 text-xs"
                    >
                      <li>
                        1. 登录
                        <a
                          href="https://dash.cloudflare.com"
                          target="_blank"
                          class="text-primary hover:underline"
                          >Cloudflare</a
                        >
                        → R2 创建存储桶
                      </li>
                      <li>
                        2. Endpoint：<code class="bg-muted px-1 rounded"
                          >{account_id}.r2.cloudflarestorage.com</code
                        >
                      </li>
                      <li>3. 在 R2 API 令牌中创建密钥</li>
                    </ul>
                  </div>
                </CollapsibleContent>
              </Collapsible>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>服务端点 (Endpoint)</Label>
                  <Input
                    v-model="form['sys.storage.oss.endpoint']"
                    :placeholder="
                      form['sys.storage.type'] === 's3'
                        ? 's3.us-east-1.amazonaws.com'
                        : form['sys.storage.type'] === 'gcs'
                          ? 'storage.googleapis.com'
                          : form['sys.storage.type'] === 'oss'
                            ? 'oss-cn-hangzhou.aliyuncs.com'
                            : form['sys.storage.type'] === 'cos'
                              ? 'cos.ap-guangzhou.myqcloud.com'
                              : 'xxxx.r2.cloudflarestorage.com'
                    "
                  />
                </div>
                <div class="grid gap-2">
                  <Label>存储桶 (Bucket)</Label>
                  <Input v-model="form['sys.storage.oss.bucket']" placeholder="my-bucket" />
                </div>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>{{
                    form['sys.storage.type'] === 'r2' ? 'Access Key ID' : 'AccessKey ID'
                  }}</Label>
                  <Input v-model="form['sys.storage.oss.accessKey']" placeholder="LTAI5t..." />
                </div>
                <div class="grid gap-2">
                  <Label>{{
                    form['sys.storage.type'] === 'r2' ? 'Secret Access Key' : 'AccessKey Secret'
                  }}</Label>
                  <Input
                    v-model="form['sys.storage.oss.secretKey']"
                    type="password"
                    placeholder="••••••••"
                  />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 地图配置 -->
      <TabsContent value="map" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>地图服务配置</CardTitle>
            <CardDescription>配置 App 使用的地图服务 API Key</CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs default-value="amap">
              <TabsList class="mb-4">
                <TabsTrigger value="amap">高德地图</TabsTrigger>
                <TabsTrigger value="tencent">腾讯地图</TabsTrigger>
                <TabsTrigger value="google">Google 地图</TabsTrigger>
              </TabsList>

              <!-- 高德地图 -->
              <TabsContent value="amap" class="space-y-4">
                <div class="flex items-center justify-between pb-4 border-b">
                  <div class="space-y-0.5">
                    <Label class="text-base">启用高德地图</Label>
                    <p class="text-sm text-muted-foreground">
                      使用高德地图作为 App 的地图服务（国内推荐）
                    </p>
                  </div>
                  <Switch v-model:checked="amapEnabled" />
                </div>
                <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                  <p>
                    1. 登录
                    <a
                      href="https://console.amap.com"
                      target="_blank"
                      class="text-primary hover:underline"
                      >高德开放平台</a
                    >
                    创建应用
                  </p>
                  <p>2. Web 服务 Key 用于后端逆地理编码、路径规划等服务</p>
                  <p>3. Web 安全密钥用于前端 JS API 调用（高德 2.0 必需）</p>
                  <p>4. Android/iOS Key 需分别创建，配置包名和 SHA1/Bundle ID</p>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="grid gap-2">
                    <Label>Web 服务 Key</Label>
                    <Input v-model="form['map.amap.webKey']" placeholder="用于前端地图和后端服务" />
                  </div>
                  <div class="grid gap-2">
                    <Label>Web 安全密钥</Label>
                    <Input
                      v-model="form['map.amap.webSecurityKey']"
                      placeholder="高德控制台获取的安全密钥"
                    />
                  </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="grid gap-2">
                    <Label>Android Key</Label>
                    <Input v-model="form['map.amap.androidKey']" placeholder="Android 应用使用" />
                  </div>
                  <div class="grid gap-2">
                    <Label>iOS Key</Label>
                    <Input v-model="form['map.amap.iosKey']" placeholder="iOS 应用使用" />
                  </div>
                </div>
              </TabsContent>

              <!-- 腾讯地图 -->
              <TabsContent value="tencent" class="space-y-4">
                <div class="flex items-center justify-between pb-4 border-b">
                  <div class="space-y-0.5">
                    <Label class="text-base">启用腾讯地图</Label>
                    <p class="text-sm text-muted-foreground">使用腾讯地图作为备选地图服务</p>
                  </div>
                  <Switch v-model:checked="tencentMapEnabled" />
                </div>
                <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                  <p>
                    1. 登录
                    <a
                      href="https://lbs.qq.com/dev/console"
                      target="_blank"
                      class="text-primary hover:underline"
                      >腾讯位置服务</a
                    >
                    创建应用
                  </p>
                  <p>2. 创建 Key 时选择「移动端」类型</p>
                  <p>3. 配置应用的包名和 SHA1 签名</p>
                </div>
                <div class="grid gap-2">
                  <Label>API Key</Label>
                  <Input v-model="form['map.tencent.key']" placeholder="腾讯位置服务 Key" />
                </div>
              </TabsContent>

              <!-- Google 地图 -->
              <TabsContent value="google" class="space-y-4">
                <div class="flex items-center justify-between pb-4 border-b">
                  <div class="space-y-0.5">
                    <Label class="text-base">启用 Google 地图</Label>
                    <p class="text-sm text-muted-foreground">为海外用户提供 Google 地图服务</p>
                  </div>
                  <Switch v-model:checked="googleMapEnabled" />
                </div>
                <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                  <p>
                    1. 登录
                    <a
                      href="https://console.cloud.google.com/google/maps-apis"
                      target="_blank"
                      class="text-primary hover:underline"
                      >Google Cloud Console</a
                    >
                  </p>
                  <p>2. 启用 Maps SDK for Android/iOS 和 Geocoding API</p>
                  <p>3. 创建 API Key 并配置应用限制，需绑定结算账号</p>
                </div>
                <div class="grid gap-2">
                  <Label>API Key</Label>
                  <Input v-model="form['map.google.key']" placeholder="Google Maps API Key" />
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 区块链存证配置 -->
      <TabsContent value="chain" class="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>区块链存证配置</CardTitle>
            <CardDescription
              >配置印记上链使用的区块链服务，将印记数据永久存储到区块链上</CardDescription
            >
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid gap-2">
              <Label>链服务提供者</Label>
              <Select v-model="form['chain.provider']">
                <SelectTrigger><SelectValue placeholder="选择链服务" /></SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="option in chainProviderOptions"
                    :key="option.dictValue"
                    :value="option.dictValue"
                  >
                    {{ option.dictLabel }}
                  </SelectItem>
                </SelectContent>
              </Select>
              <p class="text-xs text-muted-foreground">
                本地存证仅生成哈希凭证，不具备第三方背书；正式上线建议使用蚂蚁链或 BSN
              </p>
            </div>

            <!-- 本地存证说明 -->
            <div v-if="form['chain.provider'] === 'local'" class="rounded-lg bg-muted/50 p-4">
              <p class="text-sm font-medium mb-2">本地存证模式</p>
              <ul class="text-xs text-muted-foreground space-y-1">
                <li>• 零成本，无需配置第三方服务</li>
                <li>• 生成 SHA256 哈希作为存证凭证</li>
                <li>• 适合开发测试和产品演示阶段</li>
                <li>• 不具备法律效力和第三方背书</li>
              </ul>
            </div>

            <!-- 时间戳存证说明 -->
            <div v-if="form['chain.provider'] === 'timestamp'" class="rounded-lg bg-muted/50 p-4">
              <p class="text-sm font-medium mb-2">时间戳存证模式</p>
              <ul class="text-xs text-muted-foreground space-y-1">
                <li>• 通过可信时间戳服务进行存证</li>
                <li>• 具备一定的法律效力</li>
                <li>• 成本较低，适合中小规模应用</li>
                <li>• 需要配置时间戳服务 API</li>
              </ul>
            </div>

            <!-- 蚂蚁链配置 -->
            <div v-if="form['chain.provider'] === 'antchain'" class="space-y-4">
              <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                <p>
                  1. 登录
                  <a
                    href="https://antchain.antgroup.com"
                    target="_blank"
                    class="text-primary hover:underline"
                    >蚂蚁链开放平台</a
                  >
                  注册账号
                </p>
                <p>2. 创建应用，获取 AppID 和私钥</p>
                <p>3. 免费额度：1000 次/月，超出约 0.1 元/次</p>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>App ID</Label>
                  <Input v-model="form['chain.antchain.appId']" placeholder="蚂蚁链应用ID" />
                </div>
                <div class="grid gap-2">
                  <Label>API 端点</Label>
                  <Input
                    v-model="form['chain.antchain.endpoint']"
                    placeholder="https://rest.antchain.alipay.com"
                  />
                </div>
              </div>
              <div class="grid gap-2">
                <Label>私钥</Label>
                <Textarea
                  v-model="form['chain.antchain.privateKey']"
                  placeholder="-----BEGIN PRIVATE KEY-----&#10;...&#10;-----END PRIVATE KEY-----"
                  rows="4"
                  class="font-mono text-xs"
                />
              </div>
            </div>

            <!-- 时间戳存证配置 -->
            <div v-if="form['chain.provider'] === 'timestamp'" class="space-y-4">
              <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                <p>1. 选择可信时间戳服务商（如联合信任、天威诚信等）</p>
                <p>2. 注册账号并获取 API Key</p>
                <p>3. 费用：约 0.5-2 元/次，具备一定法律效力</p>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>API Key</Label>
                  <Input
                    v-model="form['chain.timestamp.apiKey']"
                    placeholder="时间戳服务 API Key"
                  />
                </div>
                <div class="grid gap-2">
                  <Label>API 端点</Label>
                  <Input
                    v-model="form['chain.timestamp.endpoint']"
                    placeholder="https://tsa.example.com/timestamp"
                  />
                </div>
              </div>
            </div>

            <!-- 腾讯至信链配置 -->
            <div v-if="form['chain.provider'] === 'zhixin'" class="space-y-4">
              <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                <p>
                  1. 登录
                  <a
                    href="https://cloud.tencent.com/product/tbaas"
                    target="_blank"
                    class="text-primary hover:underline"
                    >腾讯云区块链服务</a
                  >
                  开通至信链
                </p>
                <p>2. 创建应用，获取 SecretId 和 SecretKey</p>
                <p>3. 费用：按调用次数计费，约 0.1-0.3 元/次</p>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>Secret ID</Label>
                  <Input v-model="form['chain.zhixin.secretId']" placeholder="腾讯云 SecretId" />
                </div>
                <div class="grid gap-2">
                  <Label>Secret Key</Label>
                  <Input
                    v-model="form['chain.zhixin.secretKey']"
                    type="password"
                    placeholder="腾讯云 SecretKey"
                  />
                </div>
              </div>
              <div class="grid gap-2">
                <Label>API 端点</Label>
                <Input
                  v-model="form['chain.zhixin.endpoint']"
                  placeholder="https://tbaas.tencentcloudapi.com"
                />
              </div>
            </div>

            <!-- BSN 配置 -->
            <div v-if="form['chain.provider'] === 'bsn'" class="space-y-4">
              <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                <p>
                  1. 登录
                  <a
                    href="https://www.bsnbase.com"
                    target="_blank"
                    class="text-primary hover:underline"
                    >BSN 门户</a
                  >
                  注册账号
                </p>
                <p>2. 选择开放联盟链（如文昌链），创建项目</p>
                <p>3. 获取 API Key 和项目 ID</p>
                <p>4. 费用：约 0.05-0.2 元/次</p>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>API Key</Label>
                  <Input v-model="form['chain.bsn.apiKey']" placeholder="BSN API Key" />
                </div>
                <div class="grid gap-2">
                  <Label>项目 ID</Label>
                  <Input v-model="form['chain.bsn.projectId']" placeholder="BSN 项目ID" />
                </div>
              </div>
              <div class="grid gap-2">
                <Label>API 端点</Label>
                <Input v-model="form['chain.bsn.endpoint']" placeholder="https://api.bsngate.com" />
              </div>
            </div>

            <!-- Polygon 配置 -->
            <div v-if="form['chain.provider'] === 'polygon'" class="space-y-4">
              <div
                class="rounded-lg bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800 p-3 text-xs text-amber-800 dark:text-amber-200 space-y-1"
              >
                <p class="font-medium">⚠️ 注意事项</p>
                <p>• Polygon 是公链，国内使用可能存在合规风险</p>
                <p>• 需要钱包私钥和少量 MATIC 作为 Gas 费</p>
                <p>• 适合海外用户或去中心化需求场景</p>
              </div>
              <div class="rounded-lg bg-muted/50 p-3 text-xs text-muted-foreground space-y-1">
                <p>1. 创建以太坊钱包（MetaMask 等），切换到 Polygon 网络</p>
                <p>2. 获取少量 MATIC 作为 Gas 费（约 0.01 MATIC/笔）</p>
                <p>3. 导出钱包私钥填入下方（请妥善保管）</p>
                <p>4. RPC 推荐：polygon-rpc.com 或 Alchemy/Infura</p>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="grid gap-2">
                  <Label>RPC URL</Label>
                  <Input
                    v-model="form['chain.polygon.rpcUrl']"
                    placeholder="https://polygon-rpc.com"
                  />
                </div>
                <div class="grid gap-2">
                  <Label>合约地址（可选）</Label>
                  <Input
                    v-model="form['chain.polygon.contractAddress']"
                    placeholder="0x... 留空则直接写入交易"
                  />
                </div>
              </div>
              <div class="grid gap-2">
                <Label>钱包私钥</Label>
                <Input
                  v-model="form['chain.polygon.privateKey']"
                  type="password"
                  placeholder="0x... 请妥善保管，不要泄露"
                />
                <p class="text-xs text-destructive">私钥泄露将导致钱包资产被盗，请确保服务器安全</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>

    <!-- 未保存更改确认弹窗 -->
    <LeaveConfirmDialog
      v-model:open="showLeaveDialog"
      @confirm="confirmLeave"
      @cancel="cancelLeave"
    />
  </div>
</template>
