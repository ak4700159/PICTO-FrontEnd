import 'dart:convert';
import 'dart:typed_data';

import '../../models/photo_data.dart';

class PromptResponse {
  String response;
  List<PhotoData> photos;

  PromptResponse({required this.response, required this.photos});

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    List<PhotoData> data = [];
    if (json["photo_data"] != null) {
      data = (json["photo_data"] as List)
          .map((item) => PhotoData.fromJson(item))
          .toList();
    }
    return PromptResponse(
      response: json["response"],
      photos: data,
    );
  }
}