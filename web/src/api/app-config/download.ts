import request from '@/utils/request'

export interface FeatureItem {
  icon?: string
  title: string
  desc?: string
}

export interface DownloadConfig {
  id: string
  pageTitle?: string
  pageDescription?: string
  favicon?: string
  // 背景配置
  backgroundType: string
  backgroundImage?: string
  backgroundColor?: string
  gradientStart?: string
  gradientEnd?: string
  gradientDirection?: string
  // APP信息
  appIcon?: string
  appName?: string
  appSlogan?: string
  sloganColor?: string
  logoAnimationEnabled?: boolean
  // 按钮样式
  buttonStyle?: string
  buttonPrimaryColor?: string
  buttonSecondaryColor?: string
  buttonRadius?: string
  // 按钮文本配置
  iosButtonText?: string
  androidButtonText?: string
  featureList?: FeatureItem[]
  iosStoreUrl?: string
  androidStoreUrl?: string
  androidApkUrl?: string
  qrcodeImage?: string
  footerText?: string
  status: string
  createTime: string
  updateTime: string
}

export interface UpdateDownloadConfigParams {
  pageTitle?: string
  pageDescription?: string
  favicon?: string
  // 背景配置
  backgroundType?: string
  backgroundImage?: string
  backgroundColor?: string
  gradientStart?: string
  gradientEnd?: string
  gradientDirection?: string
  // APP信息
  appIcon?: string
  appName?: string
  appSlogan?: string
  sloganColor?: string
  logoAnimationEnabled?: boolean
  // 按钮样式
  buttonStyle?: string
  buttonPrimaryColor?: string
  buttonSecondaryColor?: string
  buttonRadius?: string
  // 按钮文本配置
  iosButtonText?: string
  androidButtonText?: string
  featureList?: FeatureItem[]
  iosStoreUrl?: string
  androidStoreUrl?: string
  androidApkUrl?: string
  qrcodeImage?: string
  footerText?: string
}

// 获取下载页配置
export function getDownloadConfig() {
  return request.get<DownloadConfig>('/admin/app-config/download')
}

// 更新下载页配置
export function updateDownloadConfig(data: UpdateDownloadConfigParams) {
  return request.put<DownloadConfig>('/admin/app-config/download', data)
}
