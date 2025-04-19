import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/google_map/marker/markder_widget.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../../../models/photo.dart';
import 'animated_marker_widget.dart';

enum PictoMarkerType { userPhoto, folderPhoto, aroundPhoto, representativePhoto, userPos }

class PictoMarker {
  // 마커의 종류
  // 1. 내 사진
  // 2. 공유폴더에 올린 다른 사람 사진
  // 3. 지역 대표 사진
  // 4. 내 주변 사진

  PictoMarkerType type;

  // not null == 실제 이미지 데이터를 메모리에 적재
  Uint8List? imageData;
  Photo photo;
  VoidCallback? onTap;

  PictoMarker({required this.photo, required this.type, this.onTap});


  factory PictoMarker.fromPhoto(Photo photo, PictoMarkerType type) {
    return PictoMarker(
      type: type,
      photo: photo,
    );
  }

  // 애니메이션 입혀진 구글 마커 반환
  Future<Marker> toAnimatedGoogleMarker({required bool most}) async {
    return Marker(
      position: LatLng(photo.lat, photo.lng),
      markerId: MarkerId(photo.photoId.toString()),
      icon: await AnimatedMarkerWidget(
        imageData: imageData,
        type: type,
      ).toBitmapDescriptor(
        // 실제 마커에 띄워질 이미지는 imageSize 파라미터에 좌지우지 된다.
        logicalSize: const Size(300, 300),
        imageSize: const Size(500, 500),
      ),
      consumeTapEvents: true,
      onTap: most ? onTap : null,
    );
  }

  // 그냥 마커 반환
  Future<Marker> toGoogleMarker({required bool most}) async {
    return Marker(
      position: LatLng(photo.lat, photo.lng),
      markerId: MarkerId(photo.photoId.toString()),
      icon: await MarkerWidget(
        imageData: imageData,
        type: type,
      ).toBitmapDescriptor(
        // 실제 마커에 띄워질 이미지는 imageSize 파라미터에 좌지우지 된다.
        logicalSize: const Size(150, 150),
        imageSize: const Size(250, 250),
      ),
      consumeTapEvents: true,
      onTap: most ? onTap : null,
    );
  }

  // 사진 식별키로 구분
  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return (other is PictoMarker && other.photo.photoId == photo.photoId);
  }

  @override
  int get hashCode => photo.photoId.hashCode;
}

