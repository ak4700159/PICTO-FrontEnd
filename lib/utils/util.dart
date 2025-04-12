import 'dart:ui';

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
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return date.toLocal().toString().substring(0, "0000-00-00 00:00".length);
}