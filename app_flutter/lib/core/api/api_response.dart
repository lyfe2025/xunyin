/// API 统一响应结构
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResponse({required this.code, required this.msg, this.data});

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}

/// 分页响应
class PageResponse<T> {
  final List<T> list;
  final int total;
  final int pageNum;
  final int pageSize;

  PageResponse({
    required this.list,
    required this.total,
    required this.pageNum,
    required this.pageSize,
  });

  bool get hasMore => pageNum * pageSize < total;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse(
      list: (json['list'] as List).map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int,
      pageNum: json['pageNum'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}
