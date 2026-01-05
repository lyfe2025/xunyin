import request from '@/utils/request'

export interface Journey {
  id: string
  cityId: string
  cityName?: string
  name: string
  theme: string
  coverImage?: string
  description?: string
  rating: number
  estimatedMinutes: number
  totalDistance: number
  completedCount: number
  pointCount?: number
  isLocked: boolean
  unlockCondition?: string
  bgmUrl?: string
  orderNum: number
  status: string
  createTime: string
  updateTime: string
}

export interface JourneyQuery {
  cityId?: string
  name?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface JourneyForm {
  id?: string
  cityId: string
  name: string
  theme: string
  coverImage?: string
  description?: string
  rating?: number
  estimatedMinutes: number
  totalDistance: number
  isLocked?: boolean
  unlockCondition?: string
  bgmUrl?: string
  orderNum?: number
  status?: string
}

export function listJourney(query: JourneyQuery) {
  return request<{ data: { list: Journey[]; total: number; pageNum: number; pageSize: number } }>({
    url: '/admin/journeys',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getJourney(id: string) {
  return request<{ data: Journey }>({
    url: `/admin/journeys/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function addJourney(data: JourneyForm) {
  return request({
    url: '/admin/journeys',
    method: 'post',
    data,
  })
}

export function updateJourney(data: JourneyForm) {
  return request({
    url: `/admin/journeys/${data.id}`,
    method: 'put',
    data,
  })
}

export function delJourney(id: string) {
  return request({
    url: `/admin/journeys/${id}`,
    method: 'delete',
  })
}

export function updateJourneyStatus(id: string, status: string) {
  return request({
    url: `/admin/journeys/${id}/status`,
    method: 'patch',
    data: { status },
  })
}

export function batchDeleteJourney(ids: string[]) {
  return request({
    url: '/admin/journeys/batch-delete',
    method: 'post',
    data: { ids },
  })
}

export function batchUpdateJourneyStatus(ids: string[], status: string) {
  return request({
    url: '/admin/journeys/batch-status',
    method: 'post',
    data: { ids, status },
  })
}

export function exportJourneys(query: JourneyQuery) {
  return request<Blob>({
    url: '/admin/journeys/export',
    method: 'get',
    params: query,
    responseType: 'blob',
  })
}
