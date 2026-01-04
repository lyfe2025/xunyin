import request from '@/utils/request'

export interface JourneyProgress {
  id: string
  userId: string
  nickname: string
  avatar: string
  phone?: string
  journeyId: string
  journeyName: string
  cityName?: string
  status: string
  startTime: string
  completeTime?: string
  timeSpentMinutes?: number
  completedPoints: number
  totalPoints: number
  createTime: string
}

export interface ProgressQuery {
  userId?: string
  nickname?: string
  journeyId?: string
  journeyName?: string
  cityId?: string
  status?: string
  pageNum?: number
  pageSize?: number
}

export interface ProgressStats {
  total: number
  inProgress: number
  completed: number
  abandoned: number
}

export function listProgress(query: ProgressQuery) {
  return request<{
    data: { list: JourneyProgress[]; total: number; pageNum: number; pageSize: number }
  }>({
    url: '/admin/progress',
    method: 'get',
    params: query,
  }).then((res: any) => res.data)
}

export function getProgress(id: string) {
  return request<{ data: JourneyProgress }>({
    url: `/admin/progress/${id}`,
    method: 'get',
  }).then((res: any) => res.data)
}

export function getProgressStats() {
  return request<{ data: ProgressStats }>({
    url: '/admin/progress/stats',
    method: 'get',
  }).then((res: any) => res.data)
}
