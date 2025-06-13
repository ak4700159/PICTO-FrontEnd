import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'comfyui_result_photo.g.dart';

@HiveType(typeId: 5)
enum ComfyuiPhotoType {
  @HiveField(0)
  removing,
  @HiveField(1)
  upscaling,
}

@HiveType(typeId: 4)
class ComfyuiResultPhoto {
  @HiveField(0)
  ComfyuiPhotoType type;

  @HiveField(1)
  Uint8List data;

  @HiveField(2)
  int createdTime;

  ComfyuiResultPhoto({required this.type, required this.data, required this.createdTime});
}
