import request from '@/utils/request'

export interface PublicSealDetail {
    id: string
    type: string
    name: string
    imageAsset: string
    description?: string | null
    badgeTitle?: string | null
    journeyName?: string | null
    cityName?: string | null
    earnedTime?: string | null
    isChained?: boolean
    txHash?: string | null
    chainTime?: string | null
    userNickname?: string | null
    userAvatar?: string | null
}

// 获取印记分享详情（公开接口）
export function getPublicSealDetail(id: string) {
    return request.get<PublicSealDetail>(`/public/seals/${id}`, {
        headers: { isToken: false },
    })
}
