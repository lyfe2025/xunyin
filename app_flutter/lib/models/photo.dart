import '../core/utils/url_utils.dart';

/// 照片
class Photo {
  final String id;
  final String? journeyId;
  final String? journeyName;
  final String? pointId;
  final String? pointName;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? filter;
  final DateTime createdAt;

  Photo({
    required this.id,
    this.journeyId,
    this.journeyName,
    this.pointId,
    this.pointName,
    required this.imageUrl,
    this.thumbnailUrl,
    this.filter,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    // 后端返回 photoUrl，兼容 imageUrl
    final imageUrl = (json['photoUrl'] ?? json['imageUrl']) as String? ?? '';
    final thumbnailUrl = json['thumbnailUrl'] as String?;
    // 后端返回 createTime 或 takenTime，兼容 createdAt
    final timeStr = (json['createTime'] ?? json['createdAt'] ?? json['takenTime']) as String?;

    return Photo(
      id: json['id'] as String,
      journeyId: json['journeyId'] as String?,
      journeyName: json['journeyName'] as String?,
      pointId: json['pointId'] as String?,
      pointName: json['pointName'] as String?,
      imageUrl: UrlUtils.getFullImageUrl(imageUrl),
      thumbnailUrl: thumbnailUrl?.isNotEmpty == true
          ? UrlUtils.getFullImageUrl(thumbnailUrl)
          : null,
      filter: json['filter'] as String?,
      createdAt: timeStr != null ? DateTime.parse(timeStr) : DateTime.now(),
    );
  }
}

/// 照片统计
class PhotoStats {
  final int totalPhotos;
  final int journeyCount;

  PhotoStats({required this.totalPhotos, required this.journeyCount});

  factory PhotoStats.fromJson(Map<String, dynamic> json) {
    return PhotoStats(
      totalPhotos: json['totalPhotos'] as int,
      journeyCount: json['journeyCount'] as int,
    );
  }
}

/// 按文化之旅分组的照片
class JourneyPhotos {
  final String journeyId;
  final String journeyName;
  final int photoCount;
  final List<Photo> photos;

  JourneyPhotos({
    required this.journeyId,
    required this.journeyName,
    required this.photoCount,
    required this.photos,
  });

  factory JourneyPhotos.fromJson(Map<String, dynamic> json) {
    return JourneyPhotos(
      journeyId: json['journeyId'] as String,
      journeyName: json['journeyName'] as String,
      photoCount: json['photoCount'] as int,
      photos: (json['photos'] as List).map((e) => Photo.fromJson(e)).toList(),
    );
  }
}
