import request from '@/utils/request'

export interface Agreement {
  id: string
  type: string
  title: string
  content: string
  version: string
  status: string
  createTime: string
  updateTime: string
}

export interface UpdateAgreementParams {
  title?: string
  content?: string
  version?: string
}

// 获取所有协议
export function listAgreements() {
  return request.get<Agreement[]>('/admin/app-config/agreements')
}

// 获取指定类型协议
export function getAgreement(type: string) {
  return request.get<Agreement>(`/admin/app-config/agreements/${type}`)
}

// 更新协议内容
export function updateAgreement(type: string, data: UpdateAgreementParams) {
  return request.put<Agreement>(`/admin/app-config/agreements/${type}`, data)
}
