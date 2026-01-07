/// 城市模型
class City {
  final String id;
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final String? iconAsset;
  final String? coverImage;
  final String? description;
  final int explorerCount;
  final String? bgmUrl;
  final int? journeyCount;

  City({
    required this.id,
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    this.iconAsset,
    this.coverImage,
    this.description,
    this.explorerCount = 0,
    this.bgmUrl,
    this.journeyCount,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    final coverImage = json['coverImage'] as String?;
    final iconAsset = json['iconAsset'] as String?;
    final bgmUrl = json['bgmUrl'] as String?;
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      iconAsset: iconAsset?.isNotEmpty == true ? iconAsset : null,
      coverImage: coverImage?.isNotEmpty == true ? coverImage : null,
      description: json['description'] as String?,
      explorerCount: json['explorerCount'] as int? ?? 0,
      bgmUrl: bgmUrl?.isNotEmpty == true ? bgmUrl : null,
      journeyCount: json['journeyCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'province': province,
    'latitude': latitude,
    'longitude': longitude,
    'iconAsset': iconAsset,
    'coverImage': coverImage,
    'description': description,
    'explorerCount': explorerCount,
    'bgmUrl': bgmUrl,
    'journeyCount': journeyCount,
  };
}

/// 附近城市（带距离）
class NearbyCity extends City {
  final double distance;

  NearbyCity({
    required super.id,
    required super.name,
    required super.province,
    required super.latitude,
    required super.longitude,
    super.iconAsset,
    super.coverImage,
    super.description,
    super.explorerCount,
    super.bgmUrl,
    super.journeyCount,
    required this.distance,
  });

  factory NearbyCity.fromJson(Map<String, dynamic> json) {
    final coverImage = json['coverImage'] as String?;
    final iconAsset = json['iconAsset'] as String?;
    final bgmUrl = json['bgmUrl'] as String?;
    return NearbyCity(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      iconAsset: iconAsset?.isNotEmpty == true ? iconAsset : null,
      coverImage: coverImage?.isNotEmpty == true ? coverImage : null,
      description: json['description'] as String?,
      explorerCount: json['explorerCount'] as int? ?? 0,
      bgmUrl: bgmUrl?.isNotEmpty == true ? bgmUrl : null,
      journeyCount: json['journeyCount'] as int?,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
