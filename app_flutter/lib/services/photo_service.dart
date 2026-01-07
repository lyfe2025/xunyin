import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/photo.dart';

class PhotoService {
  final ApiClient _api;

  PhotoService(this._api);

  /// 获取照片列表
  Future<List<Photo>> getPhotos({String? journeyId}) async {
    final params = <String, dynamic>{};
    if (journeyId != null) params['journeyId'] = journeyId;

    final response = await _api.get('/photos', queryParameters: params);
    final list = response['data'] as List;
    return list.map((e) => Photo.fromJson(e)).toList();
  }

  /// 获取照片统计
  Future<PhotoStats> getPhotoStats() async {
    final response = await _api.get('/photos/stats');
    return PhotoStats.fromJson(response['data']);
  }

  /// 按文化之旅分组获取照片
  Future<List<JourneyPhotos>> getPhotosByJourney() async {
    final response = await _api.get('/photos/by-journey');
    final list = response['data'] as List;
    return list.map((e) => JourneyPhotos.fromJson(e)).toList();
  }

  /// 上传照片
  Future<Photo> uploadPhoto({
    required File file,
    required String journeyId,
    String? pointId,
    String? filter,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'journeyId': journeyId,
      if (pointId != null) 'pointId': pointId,
      if (filter != null) 'filter': filter,
    });

    final response = await _api.post('/photos', data: formData);
    return Photo.fromJson(response['data']);
  }

  /// 删除照片
  Future<void> deletePhoto(String photoId) async {
    await _api.delete('/photos/$photoId');
  }
}
