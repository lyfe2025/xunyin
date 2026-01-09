import request from '@/utils/request'

export interface Seal {
  id: string
  type: string
  rarity: string
  name: string
  imageAsset: string
  description?: string
  unlockCondition?: string
  badgeTitle?: string
  journeyId?: string
  journeyName?: string
  cityId?: string
  cityName?: string
  collectedCount?: number
  orderNum: number
  status: string
  createTime: string
  updateTime: string
}

export interface SealQuery {
  type?: string
  rarity?: string
  name?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface SealForm {
  id?: string
  type: string
  rarity?: string
  name: string
  imageAsset: string
  description?: string
  unlockCondition?: string
  badgeTitle?: string
  journeyId?: string
  cityId?: string
  orderNum?: number
  status?: string
}

export interface SealStats {
  total: number
  byType: {
    route: number
    city: number
    special: number
  }
  byRarity: {
    common: number
    rare: number
    legendary: number
  }
  byStatus: {
    enabled: number
    disabled: number
  }
  topCollected: {
    id: string
    name: string
    type: string
    rarity: string
    imageAsset: string
    collectedCount: number
  }[]
}

export function listSeal(query: SealQuery) {
  return request<{ data: { list: Seal[]; total: number; pageNum: number; pageSize: number } }>({
    url: '/admin/seals',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getSealStats() {
  return request<{ data: SealStats }>({
    url: '/admin/seals/stats',
    method: 'get',
  }).then((res: any) => res.data)
}

export function getSeal(id: string) {
  return request<{ data: Seal }>({
    url: `/admin/seals/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function addSeal(data: SealForm) {
  return request({
    url: '/admin/seals',
    method: 'post',
    data,
  })
}

export function updateSeal(data: SealForm) {
  return request({
    url: `/admin/seals/${data.id}`,
    method: 'put',
    data,
  })
}

export function delSeal(id: string) {
  return request({
    url: `/admin/seals/${id}`,
    method: 'delete',
  })
}

export function updateSealStatus(id: string, status: string) {
  return request({
    url: `/admin/seals/${id}/status`,
    method: 'patch',
    data: { status },
  })
}

export function batchDeleteSeal(ids: string[]) {
  return request({
    url: '/admin/seals/batch-delete',
    method: 'post',
    data: { ids },
  })
}

export function batchUpdateSealStatus(ids: string[], status: string) {
  return request({
    url: '/admin/seals/batch-status',
    method: 'post',
    data: { ids, status },
  })
}

export function exportSeals(query: SealQuery) {
  return request<Blob>({
    url: '/admin/seals/export',
    method: 'get',
    params: query,
    responseType: 'blob',
  })
}
