import request from '@/utils/request'

export interface PromotionChannel {
  id: string
  channelCode: string
  channelName: string
  channelType?: string
  description?: string
  downloadUrl?: string
  qrcodeImage?: string
  status: string
  createTime: string
  updateTime: string
}

export interface PromotionStats {
  id: string
  channelId: string
  statDate: string
  pageViews: number
  downloadClicks: number
  installCount: number
  registerCount: number
  activeCount: number
  channel?: {
    channelCode: string
    channelName: string
  }
}

export interface QueryChannelParams {
  channelName?: string
  channelType?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface CreateChannelParams {
  channelCode: string
  channelName: string
  channelType?: string
  description?: string
  downloadUrl?: string
  qrcodeImage?: string
  status?: string
}

export interface UpdateChannelParams extends Partial<Omit<CreateChannelParams, 'channelCode'>> {}

export interface QueryStatsParams {
  channelId?: string
  startDate?: string
  endDate?: string
  pageNum?: number
  pageSize?: number
}

export interface StatsSummary {
  totalPageViews: number
  totalDownloadClicks: number
  totalInstallCount: number
  totalRegisterCount: number
  totalActiveCount: number
}

export interface ChannelRanking {
  channel: {
    id: string
    channelCode: string
    channelName: string
  }
  pageViews: number
  downloadClicks: number
  installCount: number
  registerCount: number
}

// ========== 渠道管理 ==========

export function listChannels(params: QueryChannelParams) {
  return request.get<{ list: PromotionChannel[]; total: number }>(
    '/admin/app-config/promotion/channels',
    { params },
  )
}

export function getChannel(id: string) {
  return request.get<PromotionChannel>(`/admin/app-config/promotion/channels/${id}`)
}

export function createChannel(data: CreateChannelParams) {
  return request.post<PromotionChannel>('/admin/app-config/promotion/channels', data)
}

export function updateChannel(id: string, data: UpdateChannelParams) {
  return request.put<PromotionChannel>(`/admin/app-config/promotion/channels/${id}`, data)
}

export function deleteChannel(id: string) {
  return request.delete(`/admin/app-config/promotion/channels/${id}`)
}

export function batchDeleteChannels(ids: string[]) {
  return request.post('/admin/app-config/promotion/channels/batch-delete', { ids })
}

// ========== 统计数据 ==========

export function listStats(params: QueryStatsParams) {
  return request.get<{ list: PromotionStats[]; total: number }>(
    '/admin/app-config/promotion/stats',
    { params },
  )
}

export function getStatsSummary(params: QueryStatsParams) {
  return request.get<StatsSummary>('/admin/app-config/promotion/stats/summary', { params })
}

export function getChannelRanking(params: QueryStatsParams) {
  return request.get<ChannelRanking[]>('/admin/app-config/promotion/stats/ranking', { params })
}
