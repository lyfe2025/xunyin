import request from '@/utils/request'

export interface City {
  id: string
  name: string
  province: string
  latitude: number
  longitude: number
  iconAsset?: string
  coverImage?: string
  description?: string
  explorerCount: number
  journeyCount?: number
  bgmUrl?: string
  orderNum: number
  status: string
  createTime: string
  updateTime: string
}

export interface CityQuery {
  name?: string
  province?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface CityForm {
  id?: string
  name: string
  province: string
  latitude: number
  longitude: number
  iconAsset?: string
  coverImage?: string
  description?: string
  bgmUrl?: string
  orderNum?: number
  status?: string
}

export function listCity(query: CityQuery) {
  return request<{ data: { list: City[]; total: number; pageNum: number; pageSize: number } }>({
    url: '/admin/cities',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getCity(id: string) {
  return request<{ data: City }>({
    url: `/admin/cities/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function addCity(data: CityForm) {
  return request({
    url: '/admin/cities',
    method: 'post',
    data,
  })
}

export function updateCity(data: CityForm) {
  return request({
    url: `/admin/cities/${data.id}`,
    method: 'put',
    data,
  })
}

export function delCity(id: string) {
  return request({
    url: `/admin/cities/${id}`,
    method: 'delete',
  })
}

export function updateCityStatus(id: string, status: string) {
  return request({
    url: `/admin/cities/${id}/status`,
    method: 'patch',
    data: { status },
  })
}

export function exportCities(query: CityQuery) {
  return request<Blob>({
    url: '/admin/cities/export',
    method: 'get',
    params: query,
    responseType: 'blob',
  })
}
