/**
 * 区块链服务提供者接口
 * 所有链服务实现都需要实现此接口
 */

export interface ChainData {
  sealId: string;
  userId: string;
  sealName: string;
  earnedTime: Date;
  location?: string;
  journeyId?: string;
}

export interface ChainResult {
  txHash: string;
  blockHeight: string;
  chainTime: Date;
  chainName: string;
  certificate?: Record<string, unknown>; // 存证原始数据，用于验证
}

export interface VerifyResult {
  valid: boolean;
  txHash: string;
  blockHeight: string;
  chainTime: Date;
  chainName: string;
  certificate?: Record<string, unknown>;
}

export interface ChainProvider {
  /**
   * 获取链名称
   */
  getChainName(): string;

  /**
   * 数据上链
   */
  chain(data: ChainData): Promise<ChainResult>;

  /**
   * 验证链上数据
   */
  verify(
    txHash: string,
    certificate?: Record<string, unknown>,
  ): Promise<VerifyResult>;
}

export const CHAIN_PROVIDER = 'CHAIN_PROVIDER';
