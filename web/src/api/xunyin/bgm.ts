import request from '@/utils/request'

export interface Bgm {
  id: string
  name: string
  url: string
  context: 'home' | 'city' | 'journey'
  contextId: string | null
  contextName: string | null
  contextCityName: string | null
  duration: number | null
  orderNum: number
  status: string
  createTime: string
}

export interface BgmQuery {
  name?: string
  context?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface BgmStats {
  total: number
  home: number
  city: number
  journey: number
}

export interface CreateBgmDto {
  name: string
  url: string
  context: 'home' | 'city' | 'journey'
  contextId?: string
  duration?: number
  orderNum?: number
  status?: string
}

export interface UpdateBgmDto {
  name?: string
  url?: string
  context?: 'home' | 'city' | 'journey'
  contextId?: string
  duration?: number
  orderNum?: number
  status?: string
}

export function listBgm(query: BgmQuery) {
  return request<{ data: { list: Bgm[]; total: number } }>({
    url: '/admin/bgm',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getBgm(id: string) {
  return request<{ data: Bgm }>({
    url: `/admin/bgm/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function getBgmStats() {
  return request<{ data: BgmStats }>({
    url: '/admin/bgm/stats',
    method: 'get',
  }).then((res: any) => res.data)
}

export function createBgm(data: CreateBgmDto) {
  return request<{ data: Bgm }>({
    url: '/admin/bgm',
    method: 'post',
    data,
  }).then((res: any) => res.data)
}

export function updateBgm(id: string, data: UpdateBgmDto) {
  return request<{ data: Bgm }>({
    url: `/admin/bgm/${id}`,
    method: 'put',
    data,
  }).then((res: any) => res.data)
}

export function updateBgmStatus(id: string, status: string) {
  return request({
    url: `/admin/bgm/${id}/status`,
    method: 'patch',
    data: { status },
  })
}

export function deleteBgm(id: string) {
  return request({
    url: `/admin/bgm/${id}`,
    method: 'delete',
  })
}

export function batchDeleteBgm(ids: string[]) {
  return request({
    url: '/admin/bgm/batch-delete',
    method: 'post',
    data: { ids },
  })
}

export function batchUpdateBgmStatus(ids: string[], status: string) {
  return request({
    url: '/admin/bgm/batch-status',
    method: 'post',
    data: { ids, status },
  })
}
