import 'dart:typed_data';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Photo {
  final int photoId;
  final int userId;
  final int? folderId;
  String photoPath; // S3 파일 경로
  final double lat;
  final double lng;
  final String location;
  final int registerDatetime;
  final int updateDatetime;
  final bool? frameActive;
  final bool? sharedActive;
  final int likes;
  final int views;
  final String tag;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoId'] as int,
      userId: json['userId'] as int,
      folderId: json['folderId'] as int?,
      photoPath: json['photoPath'] as String,
      lat: json['lat'] as double,
      lng: json['lng'] as double,
      location: json['location'] as String,
      registerDatetime: json['uploadTime'] as int,
      updateDatetime: json['uploadTime'] as int,
      frameActive: json['frameActive'] as bool?,
      sharedActive: json['sharedActive'] as bool?,
      likes: json['likes'] as int,
      views: json['views'] as int,
      tag: json['tag'] as String,
    );
  }

  Photo({
    required this.photoId,
    required this.userId,
    required this.photoPath,
    required this.registerDatetime,
    required this.updateDatetime,
    required this.lat,
    required this.lng,
    required this.likes,
    required this.views,
    required this.location,
    required this.tag,
    this.folderId,
    this.frameActive,
    this.sharedActive,
  });

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
