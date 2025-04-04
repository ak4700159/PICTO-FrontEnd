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