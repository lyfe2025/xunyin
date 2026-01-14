import request from '@/utils/request'

export interface DownloadConfig {
    id?: string
    pageTitle?: string
    pageDescription?: string
    favicon?: string
    appIcon?: string
    appName?: string
    appSlogan?: string
    sloganColor?: string
    logoAnimationEnabled?: boolean
    backgroundType?: string
    backgroundImage?: string
    backgroundColor?: string
    gradientStart?: string
    gradientEnd?: string
    gradientDirection?: string
    buttonStyle?: string
    buttonRadius?: string
    buttonPrimaryColor?: string
    buttonSecondaryColor?: string
    iosButtonText?: string
    androidButtonText?: string
    featureList?: Array<{ icon?: string; title: string }>
    iosStoreUrl?: string
    androidStoreUrl?: string
    androidApkUrl?: string
    footerText?: string
}

// 获取下载页配置（公开接口）
export function getPublicDownloadConfig() {
    return request.get<DownloadConfig>('/public/config/download', {
        headers: { isToken: false },
    })
}
