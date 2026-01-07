/// 区块链存证记录
class ChainRecord {
  final String sealId;
  final String txHash;
  final int blockHeight;
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
      blockHeight: json['blockHeight'] as int,
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
  final bool isValid;
  final String? message;
  final ChainRecord? record;

  VerifyChainResult({required this.isValid, this.message, this.record});

  factory VerifyChainResult.fromJson(Map<String, dynamic> json) {
    return VerifyChainResult(
      isValid: json['isValid'] as bool,
      message: json['message'] as String?,
      record: json['record'] != null
          ? ChainRecord.fromJson(json['record'] as Map<String, dynamic>)
          : null,
    );
  }
}
