import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

/// 上传结果
class UploadResult {
  final String url;
  final String filename;
  final int size;
  final String mimetype;

  UploadResult({
    required this.url,
    required this.filename,
    required this.size,
    required this.mimetype,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: (json['url'] as String?) ?? '',
      filename: (json['filename'] as String?) ?? '',
      size: (json['size'] as int?) ?? 0,
      mimetype: (json['mimetype'] as String?) ?? '',
    );
  }
}

/// 上传服务
class UploadService {
  final ApiClient _api;

  UploadService(this._api);

  /// 上传头像
  Future<String> uploadAvatar(File file) async {
    final result = await _uploadFile(file, '/upload/avatar');
    return result.url;
  }

  /// 上传探索照片
  Future<UploadResult> uploadPhoto(File file) async {
    return _uploadFile(file, '/upload/photo');
  }

  /// 通用文件上传
  Future<UploadResult> _uploadFile(File file, String endpoint) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await _api.dio.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('上传失败：服务器响应为空');
    }

    if (data['code'] != 200) {
      throw Exception(data['msg'] ?? '上传失败');
    }

    final resultData = data['data'];
    if (resultData == null || resultData is! Map<String, dynamic>) {
      throw Exception('上传失败：响应数据格式错误');
    }

    return UploadResult.fromJson(resultData);
  }
}
