import request from '@/utils/request'

export interface AppVersion {
  id: string
  versionCode: string
  versionName: string
  platform: string
  downloadUrl?: string
  fileSize?: string
  updateContent?: string
  isForceUpdate: boolean
  minSupportVersion?: string
  publishTime?: string
  status: string
  createTime: string
  updateTime: string
}

export interface QueryVersionParams {
  platform?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface CreateVersionParams {
  versionCode: string
  versionName: string
  platform: string
  downloadUrl?: string
  fileSize?: string
  updateContent?: string
  isForceUpdate?: boolean
  minSupportVersion?: string
  publishTime?: string
  status?: string
}

export interface UpdateVersionParams extends Partial<CreateVersionParams> {}

// 获取版本列表
export function listVersions(params: QueryVersionParams) {
  return request.get<{ list: AppVersion[]; total: number }>('/admin/app-config/versions', {
    params,
  })
}

// 获取版本详情
export function getVersion(id: string) {
  return request.get<AppVersion>(`/admin/app-config/versions/${id}`)
}

// 获取最新版本
export function getLatestVersion(platform: string) {
  return request.get<AppVersion>(`/admin/app-config/versions/latest/${platform}`)
}

// 创建版本
export function createVersion(data: CreateVersionParams) {
  return request.post<AppVersion>('/admin/app-config/versions', data)
}

// 更新版本
export function updateVersion(id: string, data: UpdateVersionParams) {
  return request.put<AppVersion>(`/admin/app-config/versions/${id}`, data)
}

// 更新版本状态
export function updateVersionStatus(id: string, status: string) {
  return request.patch(`/admin/app-config/versions/${id}/status`, { status })
}

// 删除版本
export function deleteVersion(id: string) {
  return request.delete(`/admin/app-config/versions/${id}`)
}

// 批量删除版本
export function batchDeleteVersions(ids: string[]) {
  return request.post('/admin/app-config/versions/batch-delete', { ids })
}
