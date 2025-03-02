import 'dart:typed_data';

class Photo {
  final int photoId;
  final int userId;
  String photoPath;          // S3 파일 경로
  final double? lat;
  final double? lng;
  final String? location;
  final int? registerDatetime;
  final int? updateDatetime;
  final bool? frameActive;
  final bool? sharedActive;
  final int? likes;
  final int? views;
  final String? tag;

  Photo({
    required this.photoId,
    required this.userId,
    required this.photoPath,
    this.lat,
    this.lng,
    this.location,
    required this.registerDatetime,
    required this.updateDatetime,
    this.frameActive,
    this.sharedActive,
    required this.likes,
    required this.views,
    this.tag,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as int,
      userId: json['userId'] as int,
      photoPath: json['photoPath'] as String,
      lat: json['lat'] as double?,
      lng: json['lng'] as double?,
      location: json['location'] as String?,
      registerDatetime: json['uploadTime'] as int?,
      updateDatetime: json['uploadTime'] as int?,
      frameActive: json['frameActive'] as bool?,
      sharedActive: json['sharedActive'] as bool?,
      likes: json['likes'] as int?,
      views: json['views'] as int?,
      tag: json['tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'photoId': photoId,
    'userId': userId,
    'photoPath': photoPath,
    'lat': lat,
    'lng': lng,
    'location': location,
    'registerDatetime': registerDatetime,
    'updateDatetime': updateDatetime,
    'frame_active': frameActive,
    'likes': likes,
    'views': views,
    'tag': tag,
  };
}