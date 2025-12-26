import request from '@/utils/request'

/**
 * 测试邮件发送
 */
export function testMail() {
  return request<{ success: boolean; message: string }>({
    url: '/system/mail/test',
    method: 'post',
  })
}
