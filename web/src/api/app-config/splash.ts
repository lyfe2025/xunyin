import request from '@/utils/request'

export interface SplashConfig {
  id: string
  title?: string
  type: string
  mediaUrl: string
  linkType?: string
  linkUrl?: string
  duration: number
  skipDelay: number
  platform: string
  startTime?: string
  endTime?: string
  orderNum: number
  status: string
  createTime: string
  updateTime: string
}

export interface QuerySplashParams {
  title?: string
  platform?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface CreateSplashParams {
  title?: string
  type?: string
  mediaUrl: string
  linkType?: string
  linkUrl?: string
  duration?: number
  skipDelay?: number
  platform?: string
  startTime?: string
  endTime?: string
  orderNum?: number
  status?: string
}

export interface UpdateSplashParams extends Partial<CreateSplashParams> {}

// 获取启动页配置列表
export function listSplash(params: QuerySplashParams) {
  return request.get<{ list: SplashConfig[]; total: number }>('/admin/app-config/splash', {
    params,
  })
}

// 获取启动页配置详情
export function getSplash(id: string) {
  return request.get<SplashConfig>(`/admin/app-config/splash/${id}`)
}

// 创建启动页配置
export function createSplash(data: CreateSplashParams) {
  return request.post<SplashConfig>('/admin/app-config/splash', data)
}

// 更新启动页配置
export function updateSplash(id: string, data: UpdateSplashParams) {
  return request.put<SplashConfig>(`/admin/app-config/splash/${id}`, data)
}

// 更新启动页状态
export function updateSplashStatus(id: string, status: string) {
  return request.patch(`/admin/app-config/splash/${id}/status`, { status })
}

// 删除启动页配置
export function deleteSplash(id: string) {
  return request.delete(`/admin/app-config/splash/${id}`)
}

// 批量删除启动页配置
export function batchDeleteSplash(ids: string[]) {
  return request.post('/admin/app-config/splash/batch-delete', { ids })
}
