import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import '../screens/map/google_map/marker/picto_marker.dart';

bool withinPeriod(PictoMarker m, DateTime threshhold) {
  final time = m.photo.updateDatetime ?? m.photo.registerDatetime ?? 0;
  return DateTime.fromMillisecondsSinceEpoch(time).isAfter(threshhold);
}

int compare(PictoMarker a, PictoMarker b, String sort) {
  if (sort == "좋아요순") {
    return b.photo.likes.compareTo(a.photo.likes);
  } else if (sort == "조회수순") {
    return b.photo.views.compareTo(a.photo.views);
  }
  return 0; // 기본: 정렬 안함
}

Color getColorFromUserId(int userId) {
  final int hash = userId.hashCode;
  final int r = (hash & 0xFF0000) >> 16;
  final int g = (hash & 0x00FF00) >> 8;
  final int b = (hash & 0x0000FF);
  return Color.fromARGB(255, r, g, b);
}

String formatDate(int timestamp) {
  // print("[INFO] time : $timestamp");
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return date.toLocal().toString().substring(0, "0000-00-00 00:00".length);
}

String formatDateKorean(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return "$year년 $month월 $day일 $hour시 $minute분";
}

Future<BoxFit> determineFit(Uint8List data) async {
  final codec = await ui.instantiateImageCodec(data);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final width = image.width;
  final height = image.height;
  if (width > height) {
    return BoxFit.fitWidth;
  } else {
    return BoxFit.cover;
  }
}

String? detectMimeType(Uint8List bytes) {
  if (bytes.length < 12) return null;

  if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
  if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47)
    return 'image/png';
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return 'image/gif';
  if (bytes[0] == 0x42 && bytes[1] == 0x4D) return 'image/bmp';
  if (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x01 && bytes[3] == 0x00)
    return 'image/x-icon';

  // WEBP: starts with 'RIFF....WEBP'
  if (bytes.sublist(0, 4).toString() == [82, 73, 70, 70].toString() &&
      bytes.sublist(8, 12).toString() == [87, 69, 66, 80].toString()) {
    return 'image/webp';
  }

  return null;
}

String getKoreanWeekday(int weekday) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return weekdays[(weekday - 1) % 7]; // DateTime.weekday는 1(월) ~ 7(일)
}

String convertNaturalKorean(String target) {
  final RegExp emoji = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
  String fullText = '';
  List<String> words = target.split(' ');
  for (var i = 0; i < words.length; i++) {
    String word = words[i];
    // *, # 제거
    word = word.replaceAll('*', '').replaceAll('#', '').replaceAll(':', '  ');
    fullText += emoji.hasMatch(word)
        ? word
        : word.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
    if (i < words.length - 1) fullText += ' ';
  }
  return fullText;
}
