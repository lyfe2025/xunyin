import request from '@/utils/request'

export interface DashboardStats {
  totalUsers: number
  totalCities: number
  totalJourneys: number
  totalSeals: number
  totalCompletedJourneys: number
  totalChainedSeals: number
  todayNewUsers: number
  todayCompletedJourneys: number
}

export interface TrendData {
  date: string
  count: number
}

export interface DashboardTrends {
  userTrends: TrendData[]
  journeyTrends: TrendData[]
  chainTrends: TrendData[]
}

export function getDashboardStats() {
  return request<{ data: DashboardStats }>({
    url: '/admin/dashboard/stats',
    method: 'get',
  }).then((res: any) => res.data)
}

export function getDashboardTrends(days: number = 7) {
  return request<{ data: DashboardTrends }>({
    url: '/admin/dashboard/trends',
    method: 'get',
    params: { days },
  }).then((res: any) => res.data)
}
