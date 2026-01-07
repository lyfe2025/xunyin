import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

/// 上传服务
class UploadService {
  final ApiClient _api;

  UploadService(this._api);

  /// 上传头像
  Future<String> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await _api.dio.post(
      '/upload/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data as Map<String, dynamic>;
    if (data['code'] != 200) {
      throw Exception(data['msg'] ?? '上传失败');
    }

    return data['data']['url'] as String;
  }
}
