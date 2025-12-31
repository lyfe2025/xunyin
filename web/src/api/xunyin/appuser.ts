import request from '@/utils/request'

export interface UserVerification {
  id: string
  userId: string
  realName: string
  idCardNo: string
  idCardFront?: string
  idCardBack?: string
  status: 'pending' | 'approved' | 'rejected'
  rejectReason?: string
  verifiedAt?: string
  createTime: string
  updateTime: string
  user?: {
    id: string
    nickname: string
    avatar?: string
    phone?: string
    email?: string
  }
}

export interface AppUser {
  id: string
  phone?: string
  email?: string
  nickname: string
  avatar?: string
  gender?: string // 0男 1女 2未知
  birthday?: string
  bio?: string
  openId?: string
  unionId?: string
  googleId?: string
  appleId?: string
  loginType: string // wechat/email/google/apple
  inviteCode?: string
  invitedBy?: string
  badgeTitle?: string
  totalPoints: number
  level: number
  isVerified: boolean
  lastLoginTime?: string
  lastLoginIp?: string
  status: string
  createTime: string
  updateTime: string
  verification?: {
    status: string
    realName?: string
    verifiedAt?: string
  }
}

export interface AppUserQuery {
  phone?: string
  email?: string
  nickname?: string
  loginType?: string
  isVerified?: boolean
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface VerificationQuery {
  userId?: string
  realName?: string
  status?: 'pending' | 'approved' | 'rejected'
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

// ========== 实名认证管理 ==========

export function listVerifications(query: VerificationQuery) {
  return request<{
    data: { list: UserVerification[]; total: number; pageNum: number; pageSize: number }
  }>({
    url: '/admin/appusers/verifications/list',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getVerification(id: string) {
  return request<{ data: UserVerification }>({
    url: `/admin/appusers/verifications/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function auditVerification(id: string, data: { status: 'approved' | 'rejected'; rejectReason?: string }) {
  return request({
    url: `/admin/appusers/verifications/${id}/audit`,
    method: 'put',
    data,
  })
}
