/**
 * 日期格式化工具函数
 */

/**
 * 格式化日期时间
 * @param dateString 日期字符串
 * @param format 格式化模板,默认 'YYYY-MM-DD HH:mm:ss'
 * @returns 格式化后的日期字符串
 */
export function formatDate(dateString: string | undefined, format = 'YYYY-MM-DD HH:mm:ss'): string {
  if (!dateString) return '-'
  
  const date = new Date(dateString)
  
  // 检查日期是否有效
  if (isNaN(date.getTime())) return '-'
  
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  
  return format
    .replace('YYYY', String(year))
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hours)
    .replace('mm', minutes)
    .replace('ss', seconds)
}

/**
 * 格式化日期(不含时间)
 * @param dateString 日期字符串
 * @returns 格式化后的日期字符串 YYYY-MM-DD
 */
export function formatDateOnly(dateString: string | undefined): string {
  return formatDate(dateString, 'YYYY-MM-DD')
}

/**
 * 格式化时间(不含日期)
 * @param dateString 日期字符串
 * @returns 格式化后的时间字符串 HH:mm:ss
 */
export function formatTimeOnly(dateString: string | undefined): string {
  return formatDate(dateString, 'HH:mm:ss')
}

/**
 * 相对时间格式化(如:刚刚、5分钟前、2小时前等)
 * @param dateString 日期字符串
 * @returns 相对时间描述
 */
export function formatRelativeTime(dateString: string | undefined): string {
  if (!dateString) return '-'
  
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return '-'
  
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)
  const months = Math.floor(days / 30)
  const years = Math.floor(days / 365)
  
  if (seconds < 60) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 30) return `${days}天前`
  if (months < 12) return `${months}个月前`
  return `${years}年前`
}
