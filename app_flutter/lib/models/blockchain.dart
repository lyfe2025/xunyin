/// 区块链存证记录
class ChainRecord {
  final String sealId;
  final String txHash;
  final String blockHeight;
  final DateTime chainTime;
  final String chainName;

  ChainRecord({
    required this.sealId,
    required this.txHash,
    required this.blockHeight,
    required this.chainTime,
    this.chainName = 'Polygon',
  });

  factory ChainRecord.fromJson(Map<String, dynamic> json) {
    return ChainRecord(
      sealId: json['sealId'] as String,
      txHash: json['txHash'] as String,
      blockHeight: json['blockHeight']?.toString() ?? '0',
      chainTime: DateTime.parse(json['chainTime'] as String),
      chainName: json['chainName'] as String? ?? 'Polygon',
    );
  }

  String get shortTxHash {
    if (txHash.length > 16) {
      return '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}';
    }
    return txHash;
  }
}

/// 链上验证结果
class VerifyChainResult {
  final bool valid;
  final String txHash;
  final String blockHeight;
  final DateTime chainTime;
  final String chainName;
  final String sealName;
  final String ownerNickname;
  final DateTime earnedTime;

  VerifyChainResult({
    required this.valid,
    required this.txHash,
    required this.blockHeight,
    required this.chainTime,
    required this.chainName,
    required this.sealName,
    required this.ownerNickname,
    required this.earnedTime,
  });

  factory VerifyChainResult.fromJson(Map<String, dynamic> json) {
    return VerifyChainResult(
      valid: json['valid'] as bool,
      txHash: json['txHash'] as String,
      blockHeight: json['blockHeight'] as String,
      chainTime: DateTime.parse(json['chainTime'] as String),
      chainName: json['chainName'] as String,
      sealName: json['sealName'] as String,
      ownerNickname: json['ownerNickname'] as String,
      earnedTime: DateTime.parse(json['earnedTime'] as String),
    );
  }
}

/// 上链状态
class ChainStatusResult {
  final String sealId;
  final bool isChained;
  final String? chainName;
  final String? txHash;
  final String? blockHeight;
  final DateTime? chainTime;

  ChainStatusResult({
    required this.sealId,
    required this.isChained,
    this.chainName,
    this.txHash,
    this.blockHeight,
    this.chainTime,
  });

  factory ChainStatusResult.fromJson(Map<String, dynamic> json) {
    return ChainStatusResult(
      sealId: json['sealId'] as String,
      isChained: json['isChained'] as bool,
      chainName: json['chainName'] as String?,
      txHash: json['txHash'] as String?,
      blockHeight: json['blockHeight'] as String?,
      chainTime: json['chainTime'] != null
          ? DateTime.parse(json['chainTime'] as String)
          : null,
    );
  }
}
