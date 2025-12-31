import request from '@/utils/request'

export interface UserSeal {
    id: string
    userId: string
    nickname: string
    avatar: string
    phone?: string
    sealId: string
    sealName: string
    sealImage: string
    sealType: string
    earnedTime: string
    timeSpentMinutes?: number
    pointsEarned: number
    isChained: boolean
    chainName?: string
    txHash?: string
    blockHeight?: string
    chainTime?: string
}

export interface UserSealQuery {
    userId?: string
    nickname?: string
    sealId?: string
    sealName?: string
    sealType?: string
    isChained?: boolean | string
    pageNum?: number
    pageSize?: number
}

export interface UserSealStats {
    total: number
    chained: number
    unchained: number
    byType: {
        route: number
        city: number
        special: number
    }
}

export function listUserSeal(query: UserSealQuery) {
    return request<{ data: { list: UserSeal[]; total: number; pageNum: number; pageSize: number } }>({
        url: '/admin/user-seals',
        method: 'get',
        params: query,
    }).then((res: any) => res.data)
}

export function getUserSeal(id: string) {
    return request<{ data: UserSeal }>({
        url: `/admin/user-seals/${id}`,
        method: 'get',
    }).then((res: any) => res.data)
}

export function getUserSealStats() {
    return request<{ data: UserSealStats }>({
        url: '/admin/user-seals/stats',
        method: 'get',
    }).then((res: any) => res.data)
}


export interface ChainSealParams {
    chainName?: 'antchain' | 'chainmaker' | 'zhixin'
}

export interface ChainSealResult {
    id: string
    sealId: string
    sealName: string
    userId: string
    nickname: string
    isChained: boolean
    chainName: string
    txHash: string
    blockHeight: string
    chainTime: string
}

export function chainUserSeal(id: string, params?: ChainSealParams) {
    return request<{ data: ChainSealResult }>({
        url: `/admin/user-seals/${id}/chain`,
        method: 'post',
        data: params || { chainName: 'antchain' },
    }).then((res: any) => res.data)
}
