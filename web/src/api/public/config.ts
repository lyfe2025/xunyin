import request from '@/utils/request'

export interface DownloadConfig {
    id?: string
    appIcon?: string
    appName?: string
    appSlogan?: string
    backgroundType?: string
    backgroundImage?: string
    backgroundColor?: string
    gradientStart?: string
    gradientEnd?: string
    gradientDirection?: string
    buttonRadius?: string
    buttonPrimaryColor?: string
    buttonSecondaryColor?: string
    featureList?: string[]
    iosStoreUrl?: string
    androidStoreUrl?: string
    androidApkUrl?: string
}

// 获取下载页配置（公开接口）
export function getPublicDownloadConfig() {
    return request.get<DownloadConfig>('/public/config/download', {
        headers: { isToken: false },
    })
}
