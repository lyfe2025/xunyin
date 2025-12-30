/**
 * 获取资源完整 URL
 * 将相对路径转换为可访问的资源 URL
 * 
 * 开发环境：Vite 代理会将 /uploads 转发到后端
 * 生产环境：需要拼接后端地址（如果资源不在同一域名下）
 */
export function getResourceUrl(path: string | undefined | null): string {
  if (!path) return ''

  // 已经是完整 URL（http/https/data:）
  if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:')) {
    return path
  }

  // 相对路径，直接返回（开发环境由 Vite 代理，生产环境需确保同域或配置 CDN）
  return path
}

/**
 * 检查是否为有效的图片 URL
 */
export function isValidImageUrl(url: string | undefined | null): boolean {
  if (!url) return false
  return (
    url.startsWith('http://') ||
    url.startsWith('https://') ||
    url.startsWith('/uploads/') ||
    url.startsWith('data:image/')
  )
}
