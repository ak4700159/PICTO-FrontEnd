import 'dart:typed_data';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker_widget.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../../models/photo.dart';

class PictoMarker {
  // 마커의 종류
  // 1. 내 사진
  // 2. 공유폴더에 올린 다른 사람 사진
  // 3. 지역 대표 사진
  // 4. 내 주변 사진
  int type;

  // not null == 실제 이미지 데이터를 메모리에 적재
  Uint8List? imageData;
  Photo photo;

  PictoMarker({required this.photo, required this.type});

  factory PictoMarker.fromPhoto(Photo photo, int type) {
    return PictoMarker(
      type: type,
      photo: photo,
    );
  }

  // 실제 이미지
  Future<Marker> toGoogleMarker() async {
    switch (type) {}
    return Marker(
      position: LatLng(photo.lat, photo.lng),
      markerId: MarkerId(photo.photoId.toString()),
      icon: await MarkerWidget(
        imageData: imageData,
        type: type,
      ).toBitmapDescriptor(
        logicalSize: const Size(150, 150),
        imageSize: const Size(150, 150),
      ),
    );
  }
}
