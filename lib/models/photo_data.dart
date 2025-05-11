import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';

part "photo_data.g.dart";

@HiveType(typeId: 2)
class PhotoData {
  @HiveField(0)
  int? photoId;
  @HiveField(1)
  Uint8List data;
  @HiveField(2)
  String? content;

  PhotoData({this.photoId, required this.data, this.content});

  factory PhotoData.fromJson(Map<String, dynamic> json) {
    return PhotoData(
        photoId: int.parse(json["photo_id"]),
        data: base64Decode(json["photo_bytes"]),
        content: json["content"]);
  }
}
