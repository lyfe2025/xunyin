import '../core/api/api_client.dart';
import '../models/photo.dart';

/// 创建照片请求参数
class CreatePhotoParams {
  final String journeyId;
  final String pointId;
  final String photoUrl;
  final String? thumbnailUrl;
  final String? filter;
  final double? latitude;
  final double? longitude;
  final DateTime takenTime;

  CreatePhotoParams({
    required this.journeyId,
    required this.pointId,
    required this.photoUrl,
    this.thumbnailUrl,
    this.filter,
    this.latitude,
    this.longitude,
    DateTime? takenTime,
  }) : takenTime = takenTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'journeyId': journeyId,
    'pointId': pointId,
    'photoUrl': photoUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (filter != null) 'filter': filter,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'takenTime': takenTime.toIso8601String(),
  };
}

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

  /// 创建照片记录（照片已上传后调用）
  Future<Photo> createPhoto(CreatePhotoParams params) async {
    final response = await _api.post('/photos', data: params.toJson());
    return Photo.fromJson(response['data']);
  }

  /// 获取照片详情
  Future<Photo> getPhotoDetail(String photoId) async {
    final response = await _api.get('/photos/$photoId');
    return Photo.fromJson(response['data']);
  }

  /// 删除照片
  Future<void> deletePhoto(String photoId) async {
    await _api.delete('/photos/$photoId');
  }
}
