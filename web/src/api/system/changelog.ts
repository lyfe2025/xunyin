import request from '@/utils/request'

export interface CommitInfo {
  sha: string
  shortSha: string
  message: string
  fullMessage?: string
  type: string
  date: string
  author: string
  authorAvatar?: string
}

export interface ChangelogResponse {
  rows: CommitInfo[]
  total: number
  source: 'github' | 'static'
  repoUrl?: string
}

export function getChangelog(page = 1, perPage = 30) {
  return request<{ data: ChangelogResponse }>({
    url: '/system/changelog',
    method: 'get',
    params: { page, perPage },
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  }).then((res: any) => res.data as ChangelogResponse)
}
