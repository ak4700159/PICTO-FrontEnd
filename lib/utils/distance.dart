import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';


double distance(LatLng a, LatLng b) {
  const double R = 6371e3; // 지구 반지름 (미터 단위)
  final double lat1 = a.latitude * pi / 180;
  final double lat2 = b.latitude * pi / 180;
  final double deltaLat = (b.latitude - a.latitude) * pi / 180;
  final double deltaLng = (b.longitude - a.longitude) * pi / 180;

  final double aVal = sin(deltaLat / 2) * sin(deltaLat / 2) +
      cos(lat1) * cos(lat2) *
          sin(deltaLng / 2) * sin(deltaLng / 2);

  final double c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
  final double distance = R * c;

  return distance; // 미터 단위 반환
}