import request from '@/utils/request'

export interface ExplorationPoint {
  id: string
  journeyId: string
  journeyName?: string
  cityName?: string
  name: string
  latitude: number
  longitude: number
  taskType: string
  taskDescription: string
  targetGesture?: string
  arAssetUrl?: string
  culturalBackground?: string
  culturalKnowledge?: string
  distanceFromPrev?: number
  pointsReward: number
  bgmId?: string
  bgmName?: string
  bgmUrl?: string
  orderNum: number
  status: string
  createTime: string
  updateTime: string
}

export interface PointQuery {
  journeyId?: string
  name?: string
  taskType?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface PointForm {
  id?: string
  journeyId: string
  name: string
  latitude: number
  longitude: number
  taskType: string
  taskDescription: string
  targetGesture?: string
  arAssetUrl?: string
  culturalBackground?: string
  culturalKnowledge?: string
  distanceFromPrev?: number
  pointsReward?: number
  bgmId?: string
  orderNum: number
  status?: string
}

export function listPoint(query: PointQuery) {
  return request<{
    data: { list: ExplorationPoint[]; total: number; pageNum: number; pageSize: number }
  }>({
    url: '/admin/points',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getPoint(id: string) {
  return request<{ data: ExplorationPoint }>({
    url: `/admin/points/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function addPoint(data: PointForm) {
  return request({
    url: '/admin/points',
    method: 'post',
    data,
  })
}

export function updatePoint(data: PointForm) {
  return request({
    url: `/admin/points/${data.id}`,
    method: 'put',
    data,
  })
}

export function delPoint(id: string) {
  return request({
    url: `/admin/points/${id}`,
    method: 'delete',
  })
}

export function updatePointStatus(id: string, status: string) {
  return request({
    url: `/admin/points/${id}/status`,
    method: 'patch',
    data: { status },
  })
}

export function batchUpdatePointStatus(ids: string[], status: string) {
  return request({
    url: '/admin/points/batch-status',
    method: 'patch',
    data: { ids, status },
  })
}

export function exportPoints(query: PointQuery) {
  return request<Blob>({
    url: '/admin/points/export',
    method: 'get',
    params: query,
    responseType: 'blob',
  })
}
