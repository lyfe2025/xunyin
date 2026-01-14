import request from '@/utils/request'

export interface LoginConfig {
  id: string
  // 背景配置
  backgroundType: string // image/color/gradient
  backgroundImage?: string
  backgroundColor?: string
  gradientStart?: string
  gradientMiddle?: string // 渐变中间色（3色渐变）
  gradientEnd?: string
  gradientDirection?: string
  // Aurora 底纹配置
  auroraEnabled: boolean // 是否启用 Aurora 光晕
  auroraPreset?: string // warm/standard/golden/custom
  // Logo配置
  logoImage?: string
  logoSize?: string // small/normal/large
  logoAnimationEnabled: boolean // 是否启用 Logo 浮动动画
  // 应用名称配置
  appName?: string // Logo 下方的应用名称
  appNameColor?: string // 应用名称颜色
  // 标语配置
  slogan?: string
  sloganColor?: string
  // 按钮样式
  buttonStyle?: string // filled/outlined/glass
  buttonPrimaryColor?: string // 渐变起始色
  buttonGradientEndColor?: string // 渐变结束色
  buttonSecondaryColor?: string
  buttonRadius?: string // none/sm/md/lg/full
  // 按钮文本配置
  wechatButtonText?: string
  phoneButtonText?: string
  emailButtonText?: string
  guestButtonText?: string
  // 登录方式开关
  wechatLoginEnabled: boolean
  appleLoginEnabled: boolean
  googleLoginEnabled: boolean
  phoneLoginEnabled: boolean
  emailLoginEnabled: boolean
  guestModeEnabled: boolean
  // 协议配置
  agreementSource?: string // builtin: 内置协议, external: 外部链接
  userAgreementUrl?: string
  privacyPolicyUrl?: string
  // 系统字段
  status: string
  createTime: string
  updateTime: string
}

export interface UpdateLoginConfigParams {
  // 背景配置
  backgroundType?: string
  backgroundImage?: string
  backgroundColor?: string
  gradientStart?: string
  gradientMiddle?: string
  gradientEnd?: string
  gradientDirection?: string
  // Aurora 底纹配置
  auroraEnabled?: boolean
  auroraPreset?: string
  // Logo配置
  logoImage?: string
  logoSize?: string
  logoAnimationEnabled?: boolean
  // 应用名称配置
  appName?: string
  appNameColor?: string
  // 标语配置
  slogan?: string
  sloganColor?: string
  // 按钮样式
  buttonStyle?: string
  buttonPrimaryColor?: string // 渐变起始色
  buttonGradientEndColor?: string // 渐变结束色
  buttonSecondaryColor?: string
  buttonRadius?: string
  // 按钮文本配置
  wechatButtonText?: string
  phoneButtonText?: string
  emailButtonText?: string
  guestButtonText?: string
  // 登录方式开关
  wechatLoginEnabled?: boolean
  appleLoginEnabled?: boolean
  googleLoginEnabled?: boolean
  phoneLoginEnabled?: boolean
  emailLoginEnabled?: boolean
  guestModeEnabled?: boolean
  // 协议配置
  agreementSource?: string
  userAgreementUrl?: string
  privacyPolicyUrl?: string
}

// 获取登录页配置
export function getLoginConfig() {
  return request.get<LoginConfig>('/admin/app-config/login')
}

// 更新登录页配置
export function updateLoginConfig(data: UpdateLoginConfigParams) {
  return request.put<LoginConfig>('/admin/app-config/login', data)
}
