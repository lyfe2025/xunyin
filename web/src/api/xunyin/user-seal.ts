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
  chainName?: string // 从字典 xunyin_chain_name 获取: local, timestamp, antchain, zhixin, bsn, polygon
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
    data: params,
  }).then((res: any) => res.data)
}

// 区块链配置信息
export interface ChainProviderOption {
  value: string
  label: string
  description: string
  isConfigured: boolean
  isCurrent: boolean
}

export interface ChainProviderInfo {
  currentProvider: string
  currentProviderName: string
  isConfigured: boolean
  options: ChainProviderOption[]
}

export function getChainProviderInfo() {
  return request<{ data: ChainProviderInfo }>({
    url: '/admin/blockchain/provider-info',
    method: 'get',
  }).then((res: any) => res.data)
}
