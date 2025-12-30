import request from '@/utils/request'

export interface AppUser {
  id: string
  phone?: string
  email?: string
  nickname: string
  avatar?: string
  openId?: string
  unionId?: string
  googleId?: string
  appleId?: string
  loginType: string // wechat/email/google/apple
  badgeTitle?: string
  totalPoints: number
  status: string
  createTime: string
  updateTime: string
}

export interface AppUserQuery {
  phone?: string
  email?: string
  nickname?: string
  loginType?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

// 注意：App用户管理暂时只提供查询和状态变更，不提供创建
export function listAppUser(query: AppUserQuery) {
  return request<{ data: { list: AppUser[]; total: number; pageNum: number; pageSize: number } }>({
    url: '/admin/appusers',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getAppUser(id: string) {
  return request<{ data: AppUser }>({
    url: `/admin/appusers/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function changeAppUserStatus(id: string, status: string) {
  return request({
    url: `/admin/appusers/${id}/status`,
    method: 'put',
    data: { status },
  })
}
