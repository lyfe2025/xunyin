import request from '@/utils/request'

export interface LockedAccount {
  username: string
  lockUntil: number
  remainingSeconds: number
}

/**
 * 获取被锁定的账户列表
 */
export function getLockedAccounts() {
  return request<{ rows: LockedAccount[]; total: number }>({
    url: '/auth/locked',
    method: 'get',
  })
}

/**
 * 解锁账户
 */
export function unlockAccount(username: string) {
  return request({
    url: `/auth/locked/${username}`,
    method: 'delete',
  })
}
