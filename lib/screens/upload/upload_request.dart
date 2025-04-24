import 'dart:convert';
import 'dart:io';

class UploadRequest {
  int userId;
  double lat;
  double lng;
  String? tag;
  File? file;
  bool frameActive;
  bool sharedActive;

  UploadRequest(
      {required this.userId,
      required this.lat,
      required this.lng,
      this.file,
      required this.frameActive,
      required this.sharedActive,
      this.tag});

  String toJson() {
    return jsonEncode({
      "userId": userId,
      "lat": lat,
      "lng": lng,
      "tag": tag,
      "registerTime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "frameActive": frameActive,
      "sharedActive": sharedActive,
    });
  }
}
