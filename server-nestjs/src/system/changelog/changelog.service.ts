import { Injectable } from '@nestjs/common'
import { HttpService } from '@nestjs/axios'
import { ConfigService } from '@nestjs/config'
import { LoggerService } from '../../common/logger/logger.service'
import { RedisService } from '../../redis/redis.service'
import { firstValueFrom } from 'rxjs'
import { AxiosResponse } from 'axios'
import * as fs from 'fs'
import * as path from 'path'

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

interface GitHubCommit {
  sha: string
  commit: {
    message: string
    author: {
      name: string
      date: string
    }
  }
  author?: {
    avatar_url: string
  }
}

interface CachedResult {
  rows: CommitInfo[]
  total: number
  source: 'github' | 'static'
  repoUrl?: string
}

@Injectable()
export class ChangelogService {
  private readonly GITHUB_API = 'https://api.github.com'
  private readonly CACHE_KEY_PREFIX = 'changelog:'
  private readonly CACHE_TTL = 300 // 5 分钟缓存

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly redis: RedisService,
  ) {}

  /**
   * 从环境变量获取仓库信息
   */
  private getRepoInfo(): { owner: string; repo: string } | null {
    const repoUrl = this.configService.get<string>('GIT_REPO')
    if (!repoUrl) {
      return null
    }

    // 解析 GitHub URL: https://github.com/owner/repo
    const urlMatch = repoUrl.match(/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?$/)
    if (urlMatch) {
      return { owner: urlMatch[1], repo: urlMatch[2] }
    }

    // 解析简写格式: owner/repo
    const shortMatch = repoUrl.match(/^([^/]+)\/([^/]+)$/)
    if (shortMatch) {
      return { owner: shortMatch[1], repo: shortMatch[2] }
    }

    return null
  }

  /**
   * 获取提交记录
   */
  async getCommits(
    page = 1,
    perPage = 30,
  ): Promise<{
    rows: CommitInfo[]
    total: number
    source: 'github' | 'static'
    repoUrl?: string
  }> {
    const cacheKey = `${this.CACHE_KEY_PREFIX}${page}:${perPage}`

    // 尝试从缓存获取
    try {
      const cached = await this.redis.get(cacheKey)
      if (cached) {
        this.logger.debug(`从缓存获取更新日志: ${cacheKey}`, 'ChangelogService')
        return JSON.parse(cached) as CachedResult
      }
    } catch {
      // 缓存读取失败，继续请求
    }

    const repoInfo = this.getRepoInfo()
    const repoUrl = repoInfo ? `https://github.com/${repoInfo.owner}/${repoInfo.repo}` : undefined

    let result: CachedResult

    // 尝试从 GitHub API 获取
    if (repoInfo) {
      try {
        const token = this.configService.get<string>('GIT_TOKEN')
        const data = await this.fetchFromGitHub(repoInfo, page, perPage, token)
        result = { ...data, source: 'github', repoUrl }
      } catch (error) {
        this.logger.warn(
          `GitHub API 请求失败，降级使用静态文件: ${error instanceof Error ? error.message : String(error)}`,
          'ChangelogService',
        )
        const data = this.readStaticCommitsSafe(page, perPage)
        result = { ...data, source: 'static', repoUrl }
      }
    } else {
      const data = this.readStaticCommitsSafe(page, perPage)
      result = { ...data, source: 'static', repoUrl }
    }

    // 写入缓存
    try {
      await this.redis.setex(cacheKey, this.CACHE_TTL, JSON.stringify(result))
    } catch {
      // 缓存写入失败，不影响返回
    }

    return result
  }

  private readStaticCommitsSafe(
    page: number,
    perPage: number,
  ): { rows: CommitInfo[]; total: number } {
    try {
      return this.readStaticCommits(page, perPage)
    } catch (error) {
      this.logger.error(
        `读取静态提交记录失败: ${error instanceof Error ? error.message : String(error)}`,
        'ChangelogService',
      )
      return { rows: [], total: 0 }
    }
  }

  private async fetchFromGitHub(
    repoInfo: { owner: string; repo: string },
    page: number,
    perPage: number,
    token?: string,
  ): Promise<{ rows: CommitInfo[]; total: number }> {
    const url = `${this.GITHUB_API}/repos/${repoInfo.owner}/${repoInfo.repo}/commits`
    const headers: Record<string, string> = {
      Accept: 'application/vnd.github.v3+json',
      'User-Agent': 'Xunyin-Admin',
    }

    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    const response: AxiosResponse<GitHubCommit[]> = await firstValueFrom(
      this.httpService.get<GitHubCommit[]>(url, {
        headers,
        params: { page, per_page: perPage },
        timeout: 10000,
      }),
    )

    const commits: CommitInfo[] = response.data.map((commit) => this.parseCommit(commit))
    const total: number =
      commits.length === perPage ? page * perPage + 1 : (page - 1) * perPage + commits.length

    return { rows: commits, total }
  }

  private readStaticCommits(page: number, perPage: number): { rows: CommitInfo[]; total: number } {
    const staticPath = path.join(process.cwd(), 'commits.json')

    if (!fs.existsSync(staticPath)) {
      this.logger.warn('静态提交记录文件不存在', 'ChangelogService')
      return { rows: [], total: 0 }
    }

    const content = fs.readFileSync(staticPath, 'utf-8')
    const allCommits: CommitInfo[] = JSON.parse(content) as CommitInfo[]

    const start = (page - 1) * perPage
    const rows = allCommits.slice(start, start + perPage)

    return { rows, total: allCommits.length }
  }

  private parseCommit(commit: GitHubCommit): CommitInfo {
    const fullMessage = commit.commit.message
    const firstLine = fullMessage.split('\n')[0]
    const type = this.parseCommitType(firstLine)
    const message = this.cleanMessage(firstLine)

    const hasMultipleLines = fullMessage.includes('\n') && fullMessage.trim() !== firstLine.trim()

    return {
      sha: commit.sha,
      shortSha: commit.sha.substring(0, 7),
      message,
      ...(hasMultipleLines && { fullMessage: fullMessage.trim() }),
      type,
      date: commit.commit.author.date,
      author: commit.commit.author.name,
      authorAvatar: commit.author?.avatar_url,
    }
  }

  private parseCommitType(message: string): string {
    const typeMatch = message.match(
      /^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)[(:]/,
    )
    if (typeMatch) {
      return typeMatch[1]
    }

    const cnTypeMap: Record<string, string> = {
      新增: 'feat',
      修复: 'fix',
      文档: 'docs',
      样式: 'style',
      重构: 'refactor',
      优化: 'perf',
      测试: 'test',
      构建: 'chore',
    }

    for (const [cn, en] of Object.entries(cnTypeMap)) {
      if (message.startsWith(cn)) {
        return en
      }
    }

    return 'other'
  }

  private cleanMessage(message: string): string {
    let cleaned = message.replace(
      /^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\([^)]+\))?:\s*/,
      '',
    )
    cleaned = cleaned.replace(/^(新增|修复|文档|样式|重构|优化|测试|构建):\s*/, '')
    return cleaned || message
  }
}
