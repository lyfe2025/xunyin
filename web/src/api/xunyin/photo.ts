import request from '@/utils/request'

export interface Photo {
  id: string
  userId: string
  journeyId: string
  pointId: string
  photoUrl: string
  thumbnailUrl: string | null
  filter: string | null
  latitude: number | null
  longitude: number | null
  takenTime: string
  createTime: string
  user: {
    id: string
    nickname: string
    avatar: string | null
    phone: string | null
  }
  journey: {
    id: string
    name: string
    cityId: string
    city: { name: string }
  }
  point: {
    id: string
    name: string
  }
}

export interface PhotoQuery {
  userId?: string
  nickname?: string
  journeyId?: string
  pointId?: string
  cityId?: string
  filter?: string
  startDate?: string
  endDate?: string
  pageNum?: number
  pageSize?: number
}

export interface PhotoStats {
  totalPhotos: number
  todayPhotos: number
  weekPhotos: number
  activeUsers: number
}

export function listPhoto(query: PhotoQuery) {
  // 过滤掉空字符串参数
  const params = Object.fromEntries(
    Object.entries(query).filter(([, v]) => v !== '' && v !== undefined && v !== null)
  )
  return request<{ data: { list: Photo[]; total: number } }>({
    url: '/admin/photos',
    method: 'get',
    params,
  }).then((res: any) => res.data)
}

export function getPhoto(id: string) {
  return request<{ data: Photo }>({
    url: `/admin/photos/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function getPhotoStats() {
  return request<{ data: PhotoStats }>({
    url: '/admin/photos/stats',
    method: 'get',
  }).then((res: any) => res.data)
}

export function deletePhoto(id: string) {
  return request({
    url: `/admin/photos/${id}`,
    method: 'delete',
  })
}
