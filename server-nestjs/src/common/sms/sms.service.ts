import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { RedisService } from '../../redis/redis.service'
import { LoggerService } from '../logger/logger.service'

export interface SmsConfig {
  enabled: boolean
  provider: 'aliyun' | 'tencent'
  aliyun: {
    accessKeyId: string
    accessKeySecret: string
    signName: string
    templateCode: string
  }
  tencent: {
    secretId: string
    secretKey: string
    appId: string
    signName: string
    templateId: string
  }
}

export interface SendSmsResult {
  success: boolean
  message: string
  requestId?: string
}

@Injectable()
export class SmsService {
  private readonly SMS_CODE_PREFIX = 'sms:code:'
  private readonly SMS_CODE_EXPIRE = 300 // 5分钟过期
  private readonly SMS_RATE_LIMIT_PREFIX = 'sms:rate:'
  private readonly SMS_RATE_LIMIT_EXPIRE = 60 // 1分钟内只能发送一次

  constructor(
    private prisma: PrismaService,
    private redisService: RedisService,
    private logger: LoggerService,
  ) {}

  /**
   * 从数据库获取短信配置
   */
  async getSmsConfig(): Promise<SmsConfig> {
    const configs = await this.prisma.sysConfig.findMany({
      where: {
        configKey: { startsWith: 'sms.' },
      },
    })

    const configMap: Record<string, string> = {}
    configs.forEach((c) => {
      if (c.configKey) {
        configMap[c.configKey] = c.configValue ?? ''
      }
    })

    return {
      enabled: configMap['sms.enabled'] === 'true',
      provider: (configMap['sms.provider'] as 'aliyun' | 'tencent') || 'aliyun',
      aliyun: {
        accessKeyId: configMap['sms.aliyun.accessKeyId'] || '',
        accessKeySecret: configMap['sms.aliyun.accessKeySecret'] || '',
        signName: configMap['sms.aliyun.signName'] || '',
        templateCode: configMap['sms.aliyun.templateCode'] || '',
      },
      tencent: {
        secretId: configMap['sms.tencent.secretId'] || '',
        secretKey: configMap['sms.tencent.secretKey'] || '',
        appId: configMap['sms.tencent.appId'] || '',
        signName: configMap['sms.tencent.signName'] || '',
        templateId: configMap['sms.tencent.templateId'] || '',
      },
    }
  }

  /**
   * 生成6位数字验证码
   */
  generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString()
  }

  /**
   * 检查发送频率限制
   */
  async checkRateLimit(phone: string): Promise<boolean> {
    const key = `${this.SMS_RATE_LIMIT_PREFIX}${phone}`
    const client = this.redisService.getClient()
    const exists = await client.get(key)
    return !exists
  }

  /**
   * 设置发送频率限制
   */
  async setRateLimit(phone: string): Promise<void> {
    const key = `${this.SMS_RATE_LIMIT_PREFIX}${phone}`
    const client = this.redisService.getClient()
    await client.setex(key, this.SMS_RATE_LIMIT_EXPIRE, '1')
  }

  /**
   * 保存验证码到 Redis
   */
  async saveCode(phone: string, code: string): Promise<void> {
    const key = `${this.SMS_CODE_PREFIX}${phone}`
    const client = this.redisService.getClient()
    await client.setex(key, this.SMS_CODE_EXPIRE, code)
  }

  /**
   * 验证验证码
   */
  async verifyCode(phone: string, code: string): Promise<boolean> {
    const key = `${this.SMS_CODE_PREFIX}${phone}`
    const client = this.redisService.getClient()
    const savedCode = await client.get(key)
    if (savedCode === code) {
      void client.del(key) // 验证成功后删除
      return true
    }
    return false
  }

  /**
   * 发送验证码短信
   */
  async sendVerificationCode(phone: string): Promise<SendSmsResult> {
    const config = await this.getSmsConfig()

    if (!config.enabled) {
      this.logger.warn('短信服务未启用', 'SmsService')
      return { success: false, message: '短信服务未启用' }
    }

    // 检查发送频率
    const canSend = await this.checkRateLimit(phone)
    if (!canSend) {
      return { success: false, message: '发送过于频繁，请稍后再试' }
    }

    const code = this.generateCode()

    try {
      let result: SendSmsResult

      if (config.provider === 'aliyun') {
        result = this.sendAliyunSms(phone, code, config.aliyun)
      } else {
        result = this.sendTencentSms(phone, code, config.tencent)
      }

      if (result.success) {
        await this.saveCode(phone, code)
        await this.setRateLimit(phone)
        this.logger.log(`验证码发送成功: ${phone}`, 'SmsService')
      }

      return result
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : String(err)
      this.logger.error(`短信发送失败: ${errMsg}`, undefined, 'SmsService')
      return { success: false, message: `短信发送失败: ${errMsg}` }
    }
  }

  /**
   * 阿里云短信发送（开发模式使用模拟发送）
   */
  private sendAliyunSms(phone: string, code: string, config: SmsConfig['aliyun']): SendSmsResult {
    if (!config.accessKeyId || !config.accessKeySecret) {
      return { success: false, message: '阿里云短信配置不完整' }
    }

    if (!config.signName || !config.templateCode) {
      return { success: false, message: '请配置短信签名和模板' }
    }

    // 开发模式：使用模拟发送
    // 生产环境需要安装 @alicloud/dysmsapi20170525 并实现真实发送
    this.logger.log(
      `[阿里云短信] 手机号: ${phone}, 验证码: ${code}, 签名: ${config.signName}`,
      'SmsService',
    )

    return {
      success: true,
      message: `[开发模式] 验证码: ${code}`,
      requestId: `aliyun-mock-${Date.now()}`,
    }
  }

  /**
   * 腾讯云短信发送（开发模式使用模拟发送）
   */
  private sendTencentSms(phone: string, code: string, config: SmsConfig['tencent']): SendSmsResult {
    if (!config.secretId || !config.secretKey) {
      return { success: false, message: '腾讯云短信配置不完整' }
    }

    if (!config.appId || !config.signName || !config.templateId) {
      return { success: false, message: '请配置短信AppId、签名和模板' }
    }

    // 开发模式：使用模拟发送
    // 生产环境需要安装 tencentcloud-sdk-nodejs 并实现真实发送
    this.logger.log(
      `[腾讯云短信] 手机号: ${phone}, 验证码: ${code}, 签名: ${config.signName}`,
      'SmsService',
    )

    return {
      success: true,
      message: `[开发模式] 验证码: ${code}`,
      requestId: `tencent-mock-${Date.now()}`,
    }
  }
}
