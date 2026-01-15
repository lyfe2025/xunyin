import '../core/api/api_client.dart';
import '../models/seal.dart';
import '../models/blockchain.dart';
import '../models/badge.dart';

class SealService {
  final ApiClient _api;

  SealService(this._api);

  /// 获取用户已解锁的称号列表
  Future<List<UserBadge>> getUserBadges() async {
    final response = await _api.get('/seals/badges');
    final list = response['data'] as List;
    return list.map((e) => UserBadge.fromJson(e)).toList();
  }

  /// 设置当前展示的称号
  Future<void> setBadgeTitle(String badgeTitle) async {
    await _api.put('/seals/badges/current', data: {'badgeTitle': badgeTitle});
  }

  /// 清除当前称号
  Future<void> clearBadgeTitle() async {
    await _api.delete('/seals/badges/current');
  }

  /// 获取用户印记列表
  Future<List<UserSeal>> getUserSeals({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final response = await _api.get('/seals', queryParameters: params);
    final list = response['data'] as List;
    return list.map((e) => UserSeal.fromJson(e)).toList();
  }

  /// 获取印记详情
  Future<SealDetail> getSealDetail(String sealId) async {
    final response = await _api.get('/seals/$sealId');
    return SealDetail.fromJson(response['data']);
  }

  /// 获取印记收集进度
  Future<SealProgress> getSealProgress() async {
    final response = await _api.get('/seals/progress');
    return SealProgress.fromJson(response['data']);
  }

  /// 获取所有可用印记（含未解锁）
  Future<List<SealDetail>> getAllSeals({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final response = await _api.get('/seals/available', queryParameters: params);
    final list = response['data'] as List;
    return list.map((e) => SealDetail.fromJson(e)).toList();
  }

  /// 上链存证
  Future<ChainRecord> chainSeal(String sealId) async {
    final response = await _api.post('/seals/$sealId/chain');
    return ChainRecord.fromJson(response['data']);
  }

  /// 验证链上存证
  Future<VerifyChainResult> verifyChain(String sealId, String txHash) async {
    final response = await _api.get(
      '/seals/$sealId/chain/verify',
      queryParameters: {'txHash': txHash},
    );
    return VerifyChainResult.fromJson(response['data']);
  }

  /// 查询上链状态
  Future<ChainStatusResult> getChainStatus(String sealId) async {
    final response = await _api.get('/seals/$sealId/chain/status');
    return ChainStatusResult.fromJson(response['data']);
  }
}
