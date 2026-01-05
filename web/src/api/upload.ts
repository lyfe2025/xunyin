import request from '@/utils/request'

export interface UploadResult {
  url: string
  filename: string
  size: number
  mimetype: string
  fileSize?: string // APK 上传时返回格式化的文件大小
}

/**
 * 上传用户头像
 */
export function uploadAvatar(file: File): Promise<UploadResult> {
  const formData = new FormData()
  formData.append('file', file)
  return request<{ data: UploadResult }>({
    url: '/upload/avatar',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }).then((res: unknown) => (res as { data: UploadResult }).data)
}

/**
 * 上传系统文件（Logo/Favicon）
 */
export function uploadSystem(file: File): Promise<UploadResult> {
  const formData = new FormData()
  formData.append('file', file)
  return request<{ data: UploadResult }>({
    url: '/upload/system',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }).then((res: unknown) => (res as { data: UploadResult }).data)
}

/**
 * 上传图片（通用）
 */
export function uploadImage(file: File): Promise<UploadResult> {
  const formData = new FormData()
  formData.append('file', file)
  return request<{ data: UploadResult }>({
    url: '/upload/image',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }).then((res: unknown) => (res as { data: UploadResult }).data)
}

/**
 * 上传音频文件
 */
export function uploadAudio(file: File): Promise<UploadResult> {
  const formData = new FormData()
  formData.append('file', file)
  return request<{ data: UploadResult }>({
    url: '/upload/audio',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }).then((res: unknown) => (res as { data: UploadResult }).data)
}

/**
 * 上传 APK 文件
 */
export function uploadApk(
  file: File,
  onProgress?: (percent: number) => void
): Promise<UploadResult> {
  const formData = new FormData()
  formData.append('file', file)
  return request<{ data: UploadResult }>({
    url: '/upload/apk',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    onUploadProgress: (progressEvent) => {
      if (onProgress && progressEvent.total) {
        const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        onProgress(percent)
      }
    },
  }).then((res: unknown) => (res as { data: UploadResult }).data)
}
